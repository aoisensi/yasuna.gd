@tool
extends VBoxContainer

var _cue: YSNCuePulse
var _count_spinner: EditorSpinSlider
var _wait_spinner: EditorSpinSlider


func _init(cue: YSNCuePulse) -> void:
	_cue = cue
	_cue.changed.connect(_on_cue_changed)

	custom_minimum_size = Vector2(240.0, 0.0)
	
	_count_spinner = EditorSpinSlider.new()
	_count_spinner.allow_greater = true
	_count_spinner.max_value = 100
	_count_spinner.suffix = 'times'
	add_child(_count_spinner)

	_wait_spinner = EditorSpinSlider.new()
	_wait_spinner.allow_greater = true
	_wait_spinner.max_value = 10.0
	_wait_spinner.min_value = 0.05
	_wait_spinner.step = 0.01
	_wait_spinner.suffix = 's'
	add_child(_wait_spinner)

func _on_count_spinner_changed(value: float) -> void:
	_cue.count = value

func _on_wait_spinner_changed(value: float) -> void:
	_cue.time_sec = value

func _on_cue_changed() -> void:
	if _count_spinner.value != _cue.count:
		_count_spinner.value = _cue.count
	if _wait_spinner.value != _cue.time_sec:
		_wait_spinner.value = _cue.time_sec
