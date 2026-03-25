@tool
extends GraphEdit

const _YSNGraphNode := preload('./ysn_graph_node.gd')
const _YSNGraphPopup := preload('./ysn_graph_popup.gd')


var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario

var _cue_nodes: Dictionary[int, _YSNGraphNode] = {}


func _init(scenario: YSNScenario) -> void:
	_scenario = scenario
	
	right_disconnects = true

	popup_request.connect(_on_popup_request)
	delete_nodes_request.connect(_on_delete_node_request)
	connection_request.connect(_on_connection_request.bind(true))
	disconnection_request.connect(_on_connection_request.bind(false))
	node_selected.connect(_on_node_selected)
	_scenario.changed.connect(_on_scenario_changed)

func _ready() -> void:
	_on_scenario_changed()

func _exit_tree() -> void:
	if scenario.resource_path:
		ResourceSaver.save(scenario)

func _on_scenario_changed() -> void:
	var cue_list := scenario.get_cue_list()
	var ids: Array = _cue_nodes.keys() # for remove not exsits nodes

	for id in cue_list:
		var node := _get_cue_node(id)
		if not node:
			node = _create_cue_node(id)
		node.position_offset = scenario.get_cue_position(id)
		ids.erase(id)

	for id in ids:
		_remove_cue_node(id)
	connections = scenario.get_cue_connections()

func _get_cue_node(id: int) -> _YSNGraphNode:
	return _cue_nodes.get(id)

func _create_cue_node(id: int) -> _YSNGraphNode:
	var cue := scenario.get_cue(id)
	var node := _YSNGraphNode.new(self, cue, id)
	add_child(node)
	node.name = YSNScenario._get_editor_node_name(id)
	_cue_nodes[id] = node
	return node

func _remove_cue_node(id: int) -> void:
	var node := _cue_nodes[id]
	remove_child(node)
	node.queue_free()
	_cue_nodes.erase(id)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int, is_connect: bool) -> void:
	var from := get_node(String(from_node)) as _YSNGraphNode
	var emitter_id := _cue_nodes.find_key(from)
	var emit_flow := from._cue._get_emit_flows()[from_port]
	var to := get_node(String(to_node)) as _YSNGraphNode
	var receiver_id := _cue_nodes.find_key(to)
	var receive_flow := to._cue._get_receive_flows()[to_port]
	if is_connect:
		var error := scenario.connect_cues(emitter_id, emit_flow, receiver_id, receive_flow)
		if error:
			push_error(error_string(error))
	else:
		scenario.disconnect_cues(emitter_id, emit_flow, receiver_id, receive_flow)

func _on_delete_node_request(names: Array[StringName]) -> void:
	for name in names:
		var node := get_node(String(name)) as _YSNGraphNode
		scenario.remove_cue(node._id)

func _on_node_selected(node: Node) -> void:
	if node is _YSNGraphNode:
		EditorInterface.edit_resource(node._cue)

func _on_popup_request(at_position: Vector2) -> void:
	var popup := _YSNGraphPopup.new(self)
	popup.name = &'Popup'
	add_child(popup)
	popup.popup_on_parent(Rect2(at_position + global_position, Vector2.ZERO))
	popup.spawn_position = at_position + scroll_offset
