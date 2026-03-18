@tool
extends GraphNode

const _YSNCueBegin = preload('../../resource/cue/ysn_cue_begin.gd')
const _YSNGraphEdit = preload('./ysn_graph_edit.gd') 

var _editor: _YSNGraphEdit
var _cue: YSNCue


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

	var slot_index := 0

	if _cue.has_begin_input():
		set_slot_enabled_left(0, true)
		set_slot_color_left(0, Color.WHITE)
		slot_index = 1

	if _cue.has_started_output():
		set_slot_enabled_right(0, true)
		set_slot_color_right(0, Color.WHITE)
		slot_index = 1

	if slot_index == 1:
		_add_label_control(&'started' if _cue.has_started_output() else &'')

	var custom := _cue.get_custom_control()
	if custom:
		print('added')
		print((custom as Label).text)
		add_child(custom)

func _on_position_offset_changed() -> void:
	_editor.scenario.move_cue(_cue, position_offset)

func _on_resize_end(new_size: Vector2) -> void:
	_editor.scenario.resize_cue(_cue, new_size)

func get_cue() -> YSNCue:
	return _cue
		
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
