@tool
extends GraphNode

const _YSNGraphEdit = preload('./ysn_graph_edit.gd')
const _YSNGraphNodeInspector = preload('./ysn_graph_node_inspector.gd')
const _YSNGraphNodeExtension = preload('./ysn_graph_node_extension.gd')

var _editor: _YSNGraphEdit
var _cue: YSNCue
var _inspector: _YSNGraphNodeInspector
var _id: int
var _debugger: Object
var _slots_node: Array[Control] = []
var _receive_flows: Array[StringName] = []
var _emit_flows: Array[StringName] = []
var _icon: TextureButton
var _extensions: Array[_YSNGraphNodeExtension]


func _init(editor: _YSNGraphEdit, cue: YSNCue, id: int, debugger: Object = null) -> void:
	_editor = editor
	_cue = cue
	_id = id
	_debugger = debugger
	_cue.changed.connect(_on_cue_changed)
	dragged.connect(_on_dragged)
	cue.script_changed.connect(_on_cue_script_changed.call_deferred)
	resize_request.connect(_on_resize_request)
	EditorInterface.get_editor_theme().changed.connect(_on_editor_theme_changed)

	_icon = TextureButton.new()
	_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	var titlebar := get_titlebar_hbox()
	titlebar.add_child(_icon)
	titlebar.move_child(_icon, 0)


func _ready() -> void:
	_on_cue_changed()
	_on_cue_script_changed()
	_on_editor_theme_changed()

	_extensions.clear()
	for extension in _cue._get_editor_graph_extensions():
		if extension is not _YSNGraphNodeExtension:
			push_warning()
			continue
		extension.cue = _cue
		extension.read_only = _debugger != null
		extension.debugging = _debugger != null
		extension._graph_edit = _editor
		extension._apply(self)
		_extensions.append(extension)


func _on_cue_changed() -> void:
	title = _cue._get_editor_title()
	_check_flows()
	resizable = _cue._is_editor_node_resizable()
	if not resizable:
		size = Vector2.ZERO
	get_titlebar_hbox().self_modulate = _cue._get_editor_node_color()


func _on_cue_script_changed() -> void:
	_icon.texture_normal = _cue._get_editor_icon()
	if not _cue._get_editor_graph_properties().is_empty():
		_inspector = _YSNGraphNodeInspector.new()
		_inspector.read_only = _debugger != null
		_inspector.edit(_cue)
		add_child(_inspector)
	else:
		if _inspector:
			remove_child(_inspector)
			_inspector.queue_free()
			_inspector = null


func _on_dragged(from: Vector2, to: Vector2) -> void:
	# TODO: support UndoRedo
	_editor.scenario.set_cue_position(_id, to)


func _on_editor_theme_changed() -> void:
	var theme := EditorInterface.get_editor_theme()
	_icon.modulate = theme.get_color(&'font_color', &'Label')


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
