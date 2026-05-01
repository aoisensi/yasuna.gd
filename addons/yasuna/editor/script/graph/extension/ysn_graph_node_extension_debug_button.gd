@tool
extends '../ysn_graph_node_extension.gd'

const _BUTTON_SIZE_HALF = 64
const _BUTTON_FONT_SIZE = 24

var _property: StringName


func _apply(node: GraphNode) -> void:
	var button := Button.new()
	button.disabled = not debugging
	button.text = 'DEBUG'
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override(&'font_size', _BUTTON_FONT_SIZE)
	button.custom_minimum_size = Vector2(_BUTTON_SIZE_HALF * 2, _BUTTON_SIZE_HALF * 2)
	for name in [&'disabled', &'focus', &'hover', &'normal', &'pressed']:
		_modify_style(button, name)
	button.pressed.connect(_on_button_pressed)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&'margin_bottom', 12)
	margin.add_child(button)
	node.add_child(margin)


func _modify_style(button: Button, name: StringName) -> void:
	var stylebox := button.get_theme_stylebox(name).duplicate() as StyleBoxFlat
	stylebox.corner_radius_top_left = _BUTTON_SIZE_HALF
	stylebox.corner_radius_top_right = _BUTTON_SIZE_HALF
	stylebox.corner_radius_bottom_left = _BUTTON_SIZE_HALF
	stylebox.corner_radius_bottom_right = _BUTTON_SIZE_HALF
	button.add_theme_stylebox_override(name, stylebox)


func _on_button_pressed() -> void:
	_graph_edit._debugger.emit_flow_for_debug(cue.id, &'debug')
