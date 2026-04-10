@tool
extends EditorSpinSlider

var _cue: YSNCueWait


func _init(cue: YSNCueWait, editable: bool) -> void:
	_cue = cue
	_cue.changed.connect(_on_cue_changed)

	custom_minimum_size = Vector2(240.0, 0.0)

	read_only = not editable
	allow_greater = true
	max_value = 10.0
	step = 0.01
	suffix = 's'
	value_changed.connect(_on_value_changed)


func _ready() -> void:
	_on_cue_changed()


func _on_value_changed(value: float) -> void:
	_cue.time_sec = value


func _on_cue_changed() -> void:
	if value != _cue.time_sec:
		value = _cue.time_sec
