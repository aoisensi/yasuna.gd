@tool
extends HBoxContainer

var _cue: YSNCue
var _property: StringName


func _init(cue: YSNCue, property: StringName) -> void:
	_cue = cue
	_property = property
	add_spacer(false)
	_add_button(preload('../../../icon/GuiSpinboxUp.svg'), -1)
	_add_button(preload('../../../icon/GuiSpinboxDown.svg'), +1)

func _add_button(icon: Texture2D, n: int) -> void:
	var button := Button.new()
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.icon = icon
	button.pressed.connect(_on_button_pressed.bind(n))
	add_child(button)

func _on_button_pressed(n: int) -> void:
	_cue.set(_property, _cue.get(_property) + n)
