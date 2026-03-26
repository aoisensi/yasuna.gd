@tool
extends HBoxContainer

var _cue: YSNCue
var _property: StringName


func _init(cue: YSNCue, property: StringName) -> void:
	_cue = cue
	_property = property
	add_spacer(false)
	_add_button(preload('../../../resource/icon/caret-up.svg'), -1)
	_add_button(preload('../../../resource/icon/caret-down.svg'), +1)
	var theme := EditorInterface.get_editor_theme()
	theme.changed.connect(_on_editor_theme_changed)

func _add_button(icon: Texture2D, n: int) -> void:
	var button := TextureButton.new()
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.texture_normal = icon
	button.pressed.connect(_on_button_pressed.bind(n))
	add_child(button)

func _on_button_pressed(n: int) -> void:
	_cue.set(_property, _cue.get(_property) + n)

func _on_editor_theme_changed(button: TextureButton) -> void:
	var theme := EditorInterface.get_editor_theme()
	for child in get_children():
		if child is not TextureButton:
			child.modulate = theme.get_color(&'font_color', &'Label')
