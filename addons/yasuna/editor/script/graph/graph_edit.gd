@tool
extends GraphEdit

const _GraphNodeCue := preload('./element/graph_node_cue.gd')

var _scenario: YSNScenario
var _nodes: Dictionary[int, GraphElement]
var _draggers: Dictionary[int, PackedVector2Array] = { } # [0] = from, [1] = to


func _init(scenario: YSNScenario) -> void:
	assert(scenario)
	_scenario = scenario

	right_disconnects = true

	connection_drag_started.connect(_on_connection_drag_started)
	connection_request.connect(_on_connection_request.bind(true))
	disconnection_request.connect(_on_connection_request.bind(false))
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
	connections = _scenario._get_connections()


func _on_connection_drag_started(from_node: StringName, from_port: int, is_output: bool) -> void:
	if not is_output:
		return
	var cue := _scenario.get_cue(int(str(from_node)))
	var outputs := cue._get_outputs()
	var key := '%s/%s' % [from_node, outputs[from_port].name]
	if _scenario._connections.has(key):
		force_connection_drag_end()
	# give me
	# left_disconnects = true


func _on_connection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int,
	connecting: bool,
) -> void:
	var from_cue := get_node(String(from_node)) as _GraphNodeCue
	var to_cue := get_node(String(to_node)) as _GraphNodeCue
	if not (from_cue and to_cue):
		push_error()
		return
	var outputs := from_cue._cue._get_outputs()
	var inputs := to_cue._cue._get_inputs()
	var from_flow := outputs[from_port].name as String
	var to_flow := inputs[to_port].name as String
	if connecting:
		var err := _scenario.connect_cue(from_cue._cue.id, from_flow, to_cue._cue.id, to_flow)
		if err != OK:
			push_error(error_string(err))
	else:
		_scenario.disconnect_cue(from_cue._cue.id, from_flow, to_cue._cue.id, to_flow)


func _on_end_node_move() -> void:
	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action(tr('[YSN] Move Scenario Element(s)'))
	for id in _draggers:
		var p := _draggers[id]
		undo_redo.add_do_method(_scenario, &'set_element_position', id, p[1])
		undo_redo.add_undo_method(_scenario, &'set_element_position', id, p[0])
	undo_redo.commit_action()
	_draggers.clear()


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
		node = _GraphNodeCue.new(element, self)
	if not node:
		push_error()
		return null
	node.name = str(element.id)
	add_child(node)
	_nodes[element.id] = node
	return node
