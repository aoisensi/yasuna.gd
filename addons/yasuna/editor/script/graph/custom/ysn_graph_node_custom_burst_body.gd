@tool
extends VBoxContainer

var _cue: YSNCueBurst
var _wait_spinner: EditorSpinSlider
var _count_spinner: EditorSpinSlider


func _init(cue: YSNCueBurst, editable: bool) -> void:
	_cue = cue
	_cue.changed.connect(_on_cue_changed)

	custom_minimum_size = Vector2(240.0, 0.0)

	_count_spinner = EditorSpinSlider.new()
	_count_spinner.read_only = not editable
	_count_spinner.allow_greater = true
	_count_spinner.max_value = 100
	_count_spinner.min_value = 1
	_count_spinner.editing_integer = true
	_count_spinner.suffix = ' times'
	_count_spinner.value_changed.connect(_on_count_spinner_changed)
	add_child(_count_spinner)

	_wait_spinner = EditorSpinSlider.new()
	_wait_spinner.read_only = not editable
	_wait_spinner.allow_greater = true
	_wait_spinner.max_value = 10.0
	_wait_spinner.min_value = 0.05
	_wait_spinner.step = 0.01
	_wait_spinner.suffix = 's'
	_wait_spinner.value_changed.connect(_on_wait_spinner_changed)
	add_child(_wait_spinner)

func _ready() -> void:
	_on_cue_changed()

func _on_count_spinner_changed(value: float) -> void:
	_cue.count = value

func _on_wait_spinner_changed(value: float) -> void:
	_cue.time_sec = value

func _on_cue_changed() -> void:
	if _wait_spinner.value != _cue.time_sec:
		_wait_spinner.value = _cue.time_sec
