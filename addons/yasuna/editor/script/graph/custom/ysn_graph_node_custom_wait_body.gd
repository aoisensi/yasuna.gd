@tool
extends EditorSpinSlider

var _cue: YSNCueWait


func edit(cue: YSNCueWait) -> void:
	_cue = cue
	_cue.changed.connect(_on_cue_changed)

func _init() -> void:
	custom_minimum_size = Vector2(240.0, 0.0)
	allow_greater = true
	max_value = 60.0
	step = 0.1
	suffix = 's'
	value_changed.connect(_on_value_changed)

func _on_value_changed(value: float) -> void:
	_cue.time_sec = value

func _on_cue_changed() -> void:
	if value != _cue.time_sec:
		value = _cue.time_sec
