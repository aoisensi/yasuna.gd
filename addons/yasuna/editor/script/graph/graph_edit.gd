@tool
extends GraphEdit

const _GraphNodeCue := preload('./element/graph_node_cue.gd')

var _scenario: YSNScenario
var _nodes: Dictionary[int, GraphElement]


func _init(scenario: YSNScenario) -> void:
	assert(scenario)
	_scenario = scenario

	begin_node_move.connect(_on_begin_node_move)
	end_node_move.connect(_on_end_node_move)
	delete_nodes_request.connect(_on_delete_nodes_request)

	_scenario.changed.connect(_on_scenario_changed)

	_on_scenario_changed()


func _on_scenario_changed() -> void:
	var list := _scenario.get_element_list()
	for id in _nodes:
		if not list.has(id):
			_remove_node(id)
	for id in list:
		if not _nodes.has(id):
			var element := _scenario.get_element(id)
			assert(element)
			_add_element(element)
		var node := _nodes[id]
		node.position_offset = _scenario.get_element_position(id)


func _on_begin_node_move() -> void:
	EditorInterface.get_editor_undo_redo().create_action(tr('[YSN] Move Scenario Element(s)'), UndoRedo.MERGE_ALL)


func _on_end_node_move() -> void:
	EditorInterface.get_editor_undo_redo().commit_action()


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action(tr('[YSN] Delete Scenario Element(s)'))
	for name in nodes:
		var node := _nodes[int(String(name))]
		var element: YSNElement
		if node is _GraphNodeCue:
			element = node._cue as YSNCue
		assert(element)
		var id := element.id
		var position = _scenario.get_element_position(id)
		undo_redo.add_do_method(_scenario, &'remove_element', id)
		undo_redo.add_undo_method(_scenario, &'add_element', element, position, id)
	undo_redo.commit_action()


func _remove_node(id: int) -> void:
	var node := _nodes[id]
	remove_child(node)
	node.queue_free()
	_nodes.erase(id)


func _add_element(element: YSNElement) -> GraphElement:
	assert(element.id)
	var node: GraphElement
	if element is YSNCue:
		node = _GraphNodeCue.new(element)
	if not node:
		push_error()
		return null
	node.name = str(element.id)
	add_child(node)
	_nodes[element.id] = node
	return node
