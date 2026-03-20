@tool
extends GraphNode

const _YSNCueBegin = preload('../../../script/resource/cue/ysn_cue_begin.gd')
const _YSNGraphEdit = preload('./ysn_graph_edit.gd') 

var _editor: _YSNGraphEdit
var _cue: YSNCue
var _right_slots: Array[StringName]


func _init(editor: _YSNGraphEdit, cue: YSNCue) -> void:
	_cue = cue
	_editor = editor
	name = 'Node_' + cue.resource_scene_unique_id
	_cue.changed.connect(_on_cue_changed)
	position_offset_changed.connect(_on_position_offset_changed)
	resize_end.connect(_on_resize_end)
	title = _cue.get_title()
	if _custom_body:
		add_child(_custom_body_holder)

func _ready() -> void:
	_on_cue_changed()

func _on_cue_changed() -> void:
	title = _cue.get_title()
	clear_all_slots()
	_remove_all_label_control()
	_build_slots()
	_custom_body_script = _cue.get_editor_custom_body_script()
	_custom_action_script = _cue.get_editor_custom_action_script()
	if _custom_body:
		move_child(_custom_body_holder, -1)
	resizable = _cue.is_editor_resizable_node()
	if not resizable:
		size = Vector2.ZERO

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

func _remove_all_label_control() -> void:
	for child in get_children():
		if child is HBoxContainer:
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

func _on_changed_custom_script(slot: _CustomSlot, script: Script) -> void:
	var control: Control
	if script:
		control = script.new()
		if control.has_method(&'edit'):
			control.edit(_cue)
	match slot:
		_CustomSlot.BODY:
			_custom_body = control
		_CustomSlot.ACTION:
			_custom_action = control

var _custom_body_script: Script:
	set(value):
		if _custom_body_script != value:
			_custom_body_script = value
			_on_changed_custom_script(_CustomSlot.BODY, _custom_body_script)
	get:
		return _custom_body_script

var _custom_action_script: Script:
	set(value):
		if _custom_action_script != value:
			_custom_action_script = value
			_on_changed_custom_script(_CustomSlot.ACTION, _custom_action_script)
	get:
		return _custom_action_script

var _custom_body: Control:
	set(value):
		if _custom_body == value:
			return
		if _custom_body:
			_custom_body_holder.remove_child(_custom_body)
			_custom_body.queue_free()
		_custom_body = value
		if _custom_body:
			_custom_body_holder.add_child(_custom_body)
			add_child(_custom_body_holder)
			move_child(_custom_body_holder, -1)
		else:
			remove_child(_custom_body_holder)
	get:
		return _custom_body

var _custom_action: Control:
	set(value):
		if _custom_action == value:
			return
		var hbox := get_titlebar_hbox()
		if _custom_action:
			hbox.remove_child(_custom_action)
			_custom_action.queue_free()
		_custom_action = value
		if _custom_action:
			hbox.add_child(_custom_action)

var _custom_body_holder: MarginContainer:
	get:
		if not _custom_body_holder:
			_custom_body_holder = MarginContainer.new()
			_custom_body_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
			_custom_body_holder.add_theme_constant_override(&'margin_top', 12)
			_custom_body_holder.add_theme_constant_override(&'margin_bottom', 12)
		return _custom_body_holder


enum _CustomSlot { BODY, ACTION }
