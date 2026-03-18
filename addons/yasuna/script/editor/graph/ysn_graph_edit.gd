@tool
extends GraphEdit

const _YSNGraphNode := preload('./ysn_graph_node.gd')
const _YSNGraphPopup := preload('./ysn_graph_popup.gd')
const _YSNCueBegin := preload('../../resource/cue/ysn_cue_begin.gd')

var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario
var _popup: _YSNGraphPopup

var _nodes: Dictionary[YSNCue, _YSNGraphNode] = {}


func _init(scenario: YSNScenario) -> void:
	_scenario = scenario
	
	_popup = _YSNGraphPopup.new(self)
	add_child(_popup)
	popup_request.connect(_on_popup_request)
	delete_nodes_request.connect(_on_delete_node_request)
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

func _on_delete_node_request(names: Array[StringName]) -> void:
	for name in names:
		var node := get_node(str(name)) as _YSNGraphNode
		scenario.remove_cue(node.cue)
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

func _on_node_selected(node: Node) -> void:
	if node is not _YSNGraphNode:
		return
	var cue := (node as _YSNGraphNode).get_cue()
	if cue is _YSNCueBegin:
		return
	EditorInterface.get_inspector().edit(cue)

func _on_popup_request(at_position: Vector2) -> void:
	_popup.popup_on_parent(Rect2(at_position + global_position, Vector2.ZERO))
	_popup.spawn_position = at_position + scroll_offset

func _clear() -> void:
	for child in get_children():
		if child is _YSNGraphNode:
			remove_child(child)
			child.queue_free()
