@tool
extends GraphEdit

const _YSNGraphNode := preload('./ysn_graph_node.gd')
const _YSNGraphPopup := preload('./ysn_graph_popup.gd')


var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario

var _title: LineEdit

var _cue_nodes: Dictionary[int, _YSNGraphNode] = {}

var _undo_redo := EditorInterface.get_editor_undo_redo()

var _debugger: Object


func _init(scenario: YSNScenario, debugger: Object = null) -> void:
	_scenario = scenario
	_debugger = debugger

	if not debugger:
		right_disconnects = true

		popup_request.connect(_on_popup_request)
		delete_nodes_request.connect(_on_delete_node_request)
		connection_request.connect(_on_connection_request.bind(true))
		disconnection_request.connect(_on_connection_request.bind(false))
	else:
		debugger.connect(&'flow_emitted', _on_debugger_flow_emitted)

	node_selected.connect(_on_node_selected)
	_scenario.changed.connect(_on_scenario_changed)

	_setup_toolbox(debugger)

func _ready() -> void:
	_on_scenario_changed()

func save() -> void:
	if scenario.resource_path:
		ResourceSaver.save(scenario)
		scenario.emit_changed()

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

	if not _title.is_editing():
		_title.text = scenario.title

func _get_cue_node(id: int) -> _YSNGraphNode:
	return _cue_nodes.get(id)

func _create_cue_node(id: int) -> _YSNGraphNode:
	var cue := scenario.get_cue(id)
	var node := _YSNGraphNode.new(self, cue, id, _debugger)
	if _debugger:
		node.draggable = false
	add_child(node)
	node.name = str(id)
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
		_undo_redo.create_action('Connect Cue Node')
		_connect_nodes(emitter_id, emit_flow, receiver_id, receive_flow)
	else:
		_undo_redo.create_action('Disonnect Cue Node')
		_disconnect_nodes(emitter_id, emit_flow, receiver_id, receive_flow)
	_undo_redo.commit_action()

func _on_delete_node_request(names: Array[StringName]) -> void:
	_undo_redo.create_action('Delete Scenario Cues', UndoRedo.MERGE_DISABLE, null, true)
	var ids := PackedInt32Array()
	for name in names:
		var node := get_node(String(name)) as _YSNGraphNode
		ids.append(node._id)
	_delete_nodes(ids)
	_undo_redo.commit_action()

func _on_node_selected(node: Node) -> void:
	if node is _YSNGraphNode:
		EditorInterface.edit_resource(node._cue)

func _on_popup_request(at_position: Vector2) -> void:
	var popup := _YSNGraphPopup.new(self)
	popup.name = &'Popup'
	add_child(popup)
	popup.popup_on_parent(Rect2(at_position + global_position, Vector2.ZERO))
	popup.spawn_position = at_position + scroll_offset

func _setup_toolbox(debugger: Object) -> void:
	var hbox := get_menu_hbox()
	_title = LineEdit.new()
	_title.editable = not debugger
	_title.custom_minimum_size = Vector2(240.0, 0.0)
	_title.placeholder_text = 'Title'
	_title.focus_exited.connect(_on_title_focus_exited)
	_title.keep_editing_on_text_submit = true
	_title.text_submitted.connect(_on_title_text_submitted)
	hbox.add_child(_title)
	hbox.move_child(_title, 0)

func _create_cue(script: Script, position := Vector2.ZERO) -> void:
	var cue_id := scenario.get_valid_cue_id()
	var cue := script.new() as YSNCue
	_undo_redo.create_action('Create YSNScenario Cue')
	_undo_redo.add_do_method(scenario, &'add_cue', cue, cue_id, position)
	_undo_redo.add_undo_method(scenario, &'remove_cue', cue_id)
	_undo_redo.commit_action()

func _delete_nodes(ids: PackedInt32Array) -> void:
	var connections := scenario.get_cue_connections()
	for connection in connections:
		for id in ids:
			var emitter_id: int = connection.from_node.to_int()
			var receiver_id: int = connection.to_node.to_int()
			if emitter_id == id or receiver_id == id:
				var emitter := scenario.get_cue(emitter_id)
				var receiver := scenario.get_cue(receiver_id)
				var emit_flow := emitter._get_emit_flows()[connection.from_port]
				var receive_flow := receiver._get_receive_flows()[connection.to_port]
				_disconnect_nodes(emitter_id, emit_flow, receiver_id, receive_flow)

	for id in ids:
		var node := _cue_nodes[id]
		remove_child(node)
		node.queue_free()
		_cue_nodes.erase(id)
		var cue := scenario.get_cue(id)
		var position := scenario.get_cue_position(id)
		_undo_redo.add_do_method(scenario, &'remove_cue', id)
		_undo_redo.add_undo_method(scenario, &'add_cue', cue, id, position)

func _connect_nodes(emitter_id: int, emit_flow: StringName, receiver_id: int, receive_flow: StringName) -> void:
	_undo_redo.add_do_method(scenario, &'connect_cues', emitter_id, emit_flow, receiver_id, receive_flow)
	_undo_redo.add_undo_method(scenario, &'disconnect_cues', emitter_id, emit_flow, receiver_id, receive_flow)

func _disconnect_nodes(emitter_id: int, emit_flow: StringName, receiver_id: int, receive_flow: StringName) -> void:
	_undo_redo.add_do_method(scenario, &'disconnect_cues', emitter_id, emit_flow, receiver_id, receive_flow)
	_undo_redo.add_undo_method(scenario, &'connect_cues', emitter_id, emit_flow, receiver_id, receive_flow)

func _on_debugger_flow_emitted(cue_id: int, emit_flow: StringName) -> void:
	var tween := create_tween()
	tween.tween_method(_change_node_flow_color.bind(cue_id, emit_flow), Color.GREEN, Color.WHITE, 0.25)
	tween.play()

func _change_node_flow_color(color: Color, cue_id: int, emit_flow: StringName) -> void:
	var node := _cue_nodes[cue_id]
	var cue := node._cue
	var slot := cue._get_emit_flows().find(emit_flow)
	if slot < 0:
		return
	node.set_slot_color_right(slot, color)
	var connection := scenario.get_connected_cues(cue_id, emit_flow)
	for c in connection:
		var cnode := _cue_nodes[c.cue]
		var ccue := cnode._cue
		var cslot := ccue._get_receive_flows().find(c.flow)
		if cslot < 0:
			continue
		cnode.set_slot_color_left(cslot, color)

func _on_title_text_submitted(new_text: String) -> void:
	var old_text := scenario.title
	_undo_redo.create_action('Change Scenario Title', UndoRedo.MERGE_ENDS)
	_undo_redo.add_do_property(scenario, &'title', new_text)
	_undo_redo.add_undo_property(scenario, &'title', old_text)
	_undo_redo.commit_action()

func _on_title_focus_exited() -> void:
	_title.text_submitted.emit(_title.text)
