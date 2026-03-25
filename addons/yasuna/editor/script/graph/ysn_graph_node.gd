@tool
extends GraphNode

const _YSNGraphEdit = preload('./ysn_graph_edit.gd') 


var _editor: _YSNGraphEdit
var _cue: YSNCue
var _id: int

var _slots_node: Array[Control] = []
var _receive_flows: Array[StringName] = []
var _emit_flows: Array[StringName] = []


func _init(editor: _YSNGraphEdit, cue: YSNCue, id: int) -> void:
	_editor = editor
	_cue = cue
	_id = id
	_cue.changed.connect(_on_cue_changed)
	dragged.connect(_on_dragged)
	cue.script_changed.connect(_on_cue_script_changed.call_deferred)
	resize_request.connect(_on_resize_request)

func _ready() -> void:
	_on_cue_changed()
	_on_cue_script_changed()

func _on_cue_changed() -> void:
	title = _cue._get_editor_title()
	_check_flows()
	resizable = _cue._is_editor_node_resizable()
	if not resizable:
		size = Vector2.ZERO
	get_titlebar_hbox().self_modulate = _cue._get_editor_node_color()

func _on_cue_script_changed() -> void:
	_custom_body = _cue._get_editor_custom_body()
	_custom_action = _cue._get_editor_custom_action()

func _on_dragged(from: Vector2, to: Vector2) -> void:
	_editor.scenario.set_cue_position(_id, to)

func _check_flows() -> void:
	var receive_flows := _cue._get_receive_flows()
	var emit_flows := _cue._get_emit_flows()
	if (_receive_flows.hash() == receive_flows.hash()) and (_emit_flows.hash() == emit_flows.hash()):
		return

	_receive_flows = receive_flows
	_emit_flows = emit_flows

	_rebuild_flow_nodes()

func _rebuild_flow_nodes() -> void:
	for node in _slots_node:
		remove_child(node)
		node.queue_free()
	_slots_node.clear()

	clear_all_slots()

	for i in range(max(_receive_flows.size(), _emit_flows.size())):
		var hbox := HBoxContainer.new()
		hbox.name = 'Flow_%d' % i
		if i < _receive_flows.size():
			var label := Label.new()
			label.text = _receive_flows[i]
			hbox.add_child(label)
			set_slot_enabled_left(i, true)
			set_slot_color_left(i, Color.WHITE)
		hbox.add_spacer(false)
		if i < _emit_flows.size():
			var label := Label.new()
			label.text = _emit_flows[i]
			hbox.add_child(label)
			set_slot_enabled_right(i, true)
			set_slot_color_right(i, Color.WHITE)
		add_child(hbox)
		move_child(hbox, i)
		_slots_node.append(hbox)

func _on_resize_request(new_size: Vector2) -> void:
	_editor.scenario.set_cue_size(_id, new_size)

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

var _custom_body_holder: MarginContainer:
	get:
		if not _custom_body_holder:
			_custom_body_holder = MarginContainer.new()
			_custom_body_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
			_custom_body_holder.add_theme_constant_override(&'margin_bottom', 12)
		return _custom_body_holder

var _custom_action: Control:
	set(value):
		if _custom_action == value:
			return
		var titlebar := get_titlebar_hbox()
		if _custom_action:
			titlebar.remove_child(_custom_action)
			_custom_action.queue_free()
		_custom_action = value
		if _custom_action:
			titlebar.add_child(_custom_action)
			titlebar.move_child(_custom_action, -1)
	get:
		return _custom_action


enum _CustomSlot { BODY, ACTION }
