@tool
extends PopupMenu

var scenario: YSNScenario
var at_position: Vector2


static func _is_valid_cue_script(script: Script) -> bool:
	if not script:
		return false
	if script == YSNCue:
		return true
	return _is_valid_cue_script(script.get_base_script())


func _init() -> void:
	index_pressed.connect(_on_index_pressed)

	ProjectSettings.settings_changed.connect(_on_settings_changed)
	EditorInterface.get_resource_filesystem().script_classes_updated.connect(_on_script_classes_updated)

	_on_settings_changed()


func _on_index_pressed(index: int) -> void:
	var meta := get_item_metadata(index)
	if meta is not Callable:
		push_error()
		return
	meta.call()


func _on_script_classes_updated() -> void:
	_on_settings_changed()


func _on_settings_changed() -> void:
	clear()
	for item in ProjectSettings.get_global_class_list():
		var script: Script = load(item.path)
		if script.is_abstract():
			continue
		if not script.is_tool():
			continue
		if not _is_valid_cue_script(script):
			continue
		var cue: YSNCue = script.new()

		var name := cue._editor_get_name()
		var icon := cue._editor_get_icon()
		add_icon_item(icon, name)

		set_item_metadata(item_count - 1, _pressed_add_cue.bind(script))


func _pressed_add_cue(script: Script) -> void:
	var cue: YSNCue = script.new()
	var id := scenario.get_valid_element_id()
	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action(tr('[YSN] Add Cue to Scenario'))
	undo_redo.add_do_method(scenario, &'add_element', cue, at_position, id)
	undo_redo.add_undo_method(scenario, &'remove_element', id)
	undo_redo.commit_action()
