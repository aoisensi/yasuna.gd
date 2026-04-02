@tool
extends LineEdit

var _cue: YSNCueBegin


func _init(cue: YSNCueBegin) -> void:
	_cue = cue
	_cue.changed.connect(_on_cue_changed)

	custom_minimum_size = Vector2(240.0, 0.0)

	placeholder_text = 'Empty is not available'

	text_submitted.connect(_on_text_submitted)
	text_changed.connect(_on_text_changed)
	focus_exited.connect(_on_focus_exited)

	_on_cue_changed()

func _on_cue_changed() -> void:
	text = _cue.begin_name

func _on_text_submitted(new_text: String) -> void:
	if _cue.scenario.has_begin_cue_name(new_text):
		text = _cue.begin_name
		_on_text_changed(_cue.begin_name)
		return

	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action('Change Begin Cue Name')
	undo_redo.add_do_property(_cue, &'begin_name', new_text)
	undo_redo.add_undo_property(_cue, &'begin_name', _cue.begin_name)
	undo_redo.commit_action()

func _on_text_changed(new_text: String) -> void:
	if _cue.begin_name != new_text and _cue.scenario.has_begin_cue_name(new_text):
		var theme := EditorInterface.get_editor_theme()
		add_theme_color_override(&'font_color', theme.get_color(&'error_color', &'Editor'))
	else:
		remove_theme_color_override(&'font_color')

func _on_focus_exited() -> void:
	text_submitted.emit(text)
