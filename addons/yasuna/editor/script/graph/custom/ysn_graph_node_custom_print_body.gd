@tool
extends TextEdit

var _cue: YSNCuePrint


func edit(cue: YSNCuePrint) -> void:
	_cue = cue
	_cue.changed.connect(_on_cue_changed)

func _init() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(240.0, 120.0)
	text_changed.connect(_on_text_changed)

func _on_text_changed() -> void:
	_cue.message = text

func _on_cue_changed() -> void:
	if text != _cue.message:
		text = _cue.message
