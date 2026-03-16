@tool
extends GraphEdit

const _YSNGraphNode := preload('./ysn_graph_node.gd')

var _scenario: YSNScenario


func _init(scenario: YSNScenario) -> void:
	_scenario = scenario
	
	for cue in _scenario.cues:
		var node := _add_node(cue)
		var position := _scenario.editor_positions.get(cue, Vector2.ZERO)
		node.position = position

func _add_node(cue: YSNCue) -> _YSNGraphNode:
	var node := _YSNGraphNode.new(cue)
	add_child(node)
	node.position_offset_changed.connect(_on_node_position_offset_changed.bind(node))
	return node

func _on_node_position_offset_changed(node: _YSNGraphNode) -> void:
	_scenario.editor_positions[node.cue] = node.position

func _clear() -> void:
	for child in get_children():
		if child is _YSNGraphNode:
			remove_child(child)
			child.queue_free()
