@tool
extends GraphNode

const SLOT_TYPE_DEFAULT := 0
const SLOT_COLOR := Color.WHITE
const _GraphEdit := preload('../graph_edit.gd')

var _edit: _GraphEdit
var _cue: YSNCue
var _flow_nodes: Array[Control] = []
var _icon := TextureRect.new()
var _properties: Dictionary[StringName, EditorProperty] = { }


func _init(cue: YSNCue, edit: _GraphEdit) -> void:
	assert(cue)
	assert(edit)
	_cue = cue
	_edit = edit

	_icon.custom_maximum_size = Vector2(16.0, 16.0)
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var titlebar := get_titlebar_hbox()
	titlebar.add_child(_icon)
	titlebar.move_child(_icon, 0)

	dragged.connect(_on_dragged)
	node_selected.connect(_on_node_selected)

	_cue.changed.connect(_on_cue_changed)
	_cue.script_changed.connect(_on_cue_script_changed)
	_cue.flows_changed.connect(_on_cue_flows_changed)

	_on_cue_script_changed()
	_on_cue_flows_changed()


#region Signal
func _on_node_selected() -> void:
	EditorInterface.inspect_object(_cue)


func _on_dragged(from: Vector2, to: Vector2) -> void:
	_edit._draggers[_cue.id] = PackedVector2Array([from, to])
#endregion


#region Cue Signal
func _on_cue_script_changed() -> void:
	title = _cue._editor_get_name()
	var icon := _cue._editor_get_icon()
	_icon.visible = icon != null
	if icon:
		_icon.texture = icon


func _on_cue_flows_changed() -> void:
	_rebuild_controls()


func _on_cue_changed() -> void:
	for path in _properties:
		var property := _properties[path]
		property.update_property()


func _on_property_property_changed(
	property: StringName,
	value: Variant,
	field: StringName,
	changing: bool,
) -> void:
	var old := _cue.get(property)
	if old == value:
		return
	_cue.set(property, value)
#endregion


#region Node
func _rebuild_controls() -> void:
	clear_all_slots()
	_rebuild_flows()
	_rebuild_properties()


func _rebuild_flows() -> void:
	for child in _flow_nodes:
		remove_child(child)
		child.queue_free()
	_flow_nodes.clear()
	var inputs := _cue._get_inputs()
	var outputs := _cue._get_outputs()
	for i in range(max(inputs.size(), outputs.size())):
		var hbox := HBoxContainer.new()
		hbox.custom_minimum_size.y = 32.0
		if i < inputs.size():
			_add_flow_label(hbox, inputs[i], YSNCue.INPUT_DO)
			set_slot_enabled_left(i, true)
			set_slot_color_left(i, SLOT_COLOR)
			set_slot_type_left(i, SLOT_TYPE_DEFAULT)
		hbox.add_spacer(false)
		if i < outputs.size():
			_add_flow_label(hbox, outputs[i], YSNCue.OUTPUT_THEN)
			set_slot_enabled_right(i, true)
			set_slot_color_right(i, SLOT_COLOR)
			set_slot_type_right(i, SLOT_TYPE_DEFAULT)
		_flow_nodes.append(hbox)
		add_child(hbox)


func _add_flow_label(hbox: HBoxContainer, item: Dictionary, skip: String) -> void:
	var name := item.name as String
	if name == skip:
		return
	var label := Label.new()
	label.text = name.capitalize()
	hbox.add_child(label)


func _rebuild_properties() -> void:
	_properties.clear()
	for path in _cue._editor_get_properties():
		var info := _get_property_info(_cue, path)
		var property := EditorInspector.instantiate_property_editor(
			_cue,
			info.get(&'type', 0),
			path,
			info.get(&'hint', 0),
			info.get(&'hint_string', ''),
			info.get(&'usage', 0),
		)
		property.set_object_and_property(_cue, path)
		property.custom_minimum_size.x = 240.0
		property.draw_label = false
		property.property_changed.connect(_on_property_property_changed)
		add_child(property)
		property.update_property()
		_properties[path] = property
#endregion


func _get_property_info(object: Object, name: StringName) -> Dictionary:
	for property in object.get_property_list():
		if property.name == name:
			return property
	return { }
