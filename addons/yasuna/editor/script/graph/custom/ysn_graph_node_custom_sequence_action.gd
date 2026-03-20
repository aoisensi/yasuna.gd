@tool
extends HBoxContainer

var _cue: YSNCueSequence


func edit(cue: YSNCueSequence) -> void:
	_cue = cue


func _init() -> void:
	add_spacer(false)
	_build_button(preload('../../../icon/GuiSpinboxUp.svg'), -1)
	_build_button(preload('../../../icon/GuiSpinboxDown.svg'), +1)

func _build_button(icon: Texture2D, n: int) -> void:
	var button := Button.new()
	button.icon = icon
	button.pressed.connect(_on_button_pressed.bind(n))
	add_child(button)

func _on_button_pressed(n: int) -> void:
	_cue.count = clampi(_cue.count + n, 1, 100)
