@tool
extends GraphEdit

const _YSNGraphNode := preload('./ysn_graph_node.gd')
const _YSNGraphPopup := preload('./ysn_graph_popup.gd')
const _YSNCueBegin := preload('../../../script/resource/cue/ysn_cue_begin.gd')

var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario
var _popup: _YSNGraphPopup

var _nodes: Dictionary[YSNCue, _YSNGraphNode] = {}

var _connections_cache: Dictionary[YSNCue, Array] = {}


func _init(scenario: YSNScenario) -> void:
	_scenario = scenario
	
	right_disconnects = true

	_popup = _YSNGraphPopup.new(self)
	add_child(_popup)
	popup_request.connect(_on_popup_request)
	delete_nodes_request.connect(_on_delete_node_request)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	node_selected.connect(_on_node_selected)
	_scenario.changed.connect(_on_scenario_changed)

func _ready() -> void:
	_on_scenario_changed()

func _exit_tree() -> void:
	ResourceSaver.save(scenario)

func _add_node(cue: YSNCue) -> _YSNGraphNode:
	var node := _YSNGraphNode.new(self, cue)
	add_child(node)
	_nodes[cue] = node
	return node

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if to_port != 0:
		push_error('Port number %d is not supported. [BUG]' % to_port)
		return
	var from_cue := _get_node_by_name(from_node).get_cue()
	var to_cue := _get_node_by_name(to_node).get_cue()
	var output := from_cue.get_outputs()[from_port]
	scenario.connect_cue(from_cue, output, to_cue)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if to_port != 0:
		push_error('Port number %d is not supported. [BUG]' % to_port)
		return
	var from_cue := _get_node_by_name(from_node).get_cue()
	var to_cue := _get_node_by_name(to_node).get_cue()
	var output := from_cue.get_outputs()[from_port]
	scenario.disconnect_cue(from_cue, output, to_cue)

func _on_delete_node_request(names: Array[StringName]) -> void:
	for name in names:
		var node := _get_node_by_name(name)
		scenario.remove_cue(node.get_cue())
		remove_child(node)
		node.queue_free()

func _on_scenario_changed() -> void:
	var cues := _scenario.get_cues()
	for cue in cues:
		var node: _YSNGraphNode = _nodes.get(cue)
		if not node:
			node = _add_node(cue)
		node.position_offset = _scenario.get_cue_position(cue)
		node.size = _scenario.get_cue_size(cue)

		_cache_cue_connections(cue)
	_apply_connections_by_cache()

func _on_node_selected(node: Node) -> void:
	if node is not _YSNGraphNode:
		return
	var cue := (node as _YSNGraphNode).get_cue()
	if cue is _YSNCueBegin:
		return
	EditorInterface.edit_resource(cue)

func _on_popup_request(at_position: Vector2) -> void:
	_popup.popup_on_parent(Rect2(at_position + global_position, Vector2.ZERO))
	_popup.spawn_position = at_position + scroll_offset

func _clear() -> void:
	for child in get_children():
		if child is _YSNGraphNode:
			remove_child(child)
			child.queue_free()

func _get_node_by_name(name: StringName) -> _YSNGraphNode:
	return get_node(str(name)) as _YSNGraphNode

func _cache_cue_connections(cue: YSNCue) -> void:
	var cache: Array[Dictionary] = []
	var from_node := _nodes[cue]
	var from_outputs := cue.get_outputs()
	var conns := scenario._get_cue_data_connections(cue)
	for output in from_outputs:
		var from_port := from_outputs.find(output)
		var nexts := scenario.get_next_cues(cue, output)
		for to_cue in nexts:
			var to_node := _nodes.get(to_cue)
			if not to_node:
				continue
			cache.append({
				&'from_node': from_node.name,
				&'from_port': from_port,
				&'to_node': to_node.name,
				&'to_port': 0, # always 0
				&'keep_alive': false,
			})
	_connections_cache[cue] = cache

func _apply_connections_by_cache() -> void:
	var conns := []
	for conn in _connections_cache.values():
		conns.append_array(conn)
	connections = conns
