@tool
extends GraphNode

const _YSNCueBegin = preload('../../resource/cue/ysn_cue_begin.gd')
const _YSNGraphEdit = preload('./ysn_graph_edit.gd') 

var _editor: _YSNGraphEdit
var _cue: YSNCue
var _right_slots: Array[StringName]

func _init(editor: _YSNGraphEdit, cue: YSNCue) -> void:
	_cue = cue
	_editor = editor
	_cue.changed.connect(_on_cue_changed)
	position_offset_changed.connect(_on_position_offset_changed)
	resize_end.connect(_on_resize_end)
	resizable = true
	title = _cue.get_title()

func _ready() -> void:
	_on_cue_changed()

func _exit_tree() -> void:
	_clear_all_child()

func _on_cue_changed() -> void:
	title = _cue.get_title()
	clear_all_slots()
	_clear_all_child()

	_build_slots()

func _on_position_offset_changed() -> void:
	_editor.scenario.move_cue(_cue, position_offset)

func _on_resize_end(new_size: Vector2) -> void:
	_editor.scenario.resize_cue(_cue, new_size)

func get_cue() -> YSNCue:
	return _cue

func _build_slots() -> void:
	_right_slots = _cue.get_outputs()

	var added := false

	for index in range(_right_slots.size()):
		if _right_slots.size() > index:
			_add_label_control(_right_slots[index])
			set_slot_enabled_right(index, true)
		else:
			_add_label_control(&'')
		added = true
	
	if _cue is not _YSNCueBegin:
		set_slot_enabled_left(0, true)
		if not added:
			_add_label_control(&'')

func _clear_all_child() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _add_label_control(right: StringName) -> void:
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_spacer(false)
	if right:
		var label := Label.new()
		label.text = right
		hbox.add_child(label)
	add_child(hbox)

func _get_connections() -> Array[Dictionary]:
	var connections: Array[Dictionary] = []
	var output_names := _cue.get_outputs()
	for from_port_name in _cue._outputs.keys():
		var dict := _cue._outputs[from_port_name]
		var from_port := output_names.find(from_port_name)
		for to_cue in dict.keys():
			connections.append({
				&'from_node': name,
				&'from_port': from_port,
				&'to_node': _editor._nodes[to_cue].name,
				&'to_port': 0,
				&'keep_alive': false,
			})
	return connections
