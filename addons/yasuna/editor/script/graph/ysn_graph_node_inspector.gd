extends MarginContainer

var read_only := false
var _margin: MarginContainer
var _vbox: VBoxContainer
var _cue: YSNCue
var _editors: Dictionary[StringName, EditorProperty]


func _init() -> void:
	custom_minimum_size.x = 240.0
	add_theme_constant_override(&'margin_bottom', 12)
	_vbox = VBoxContainer.new()
	add_child(_vbox)


func edit(cue: YSNCue) -> void:
	if _cue == cue:
		return
	if _cue:
		_cue.property_list_changed.disconnect(_on_cue_property_list_changed)
		_cue.changed.disconnect(_on_cue_changed)
	_cue = cue
	if _cue:
		_cue.property_list_changed.connect(_on_cue_property_list_changed)
		_cue.changed.connect(_on_cue_changed)
		_on_cue_property_list_changed()
		_on_cue_changed()


func _on_cue_changed() -> void:
	for name in _editors:
		var editor := _editors[name]
		editor.update_property()


func _on_cue_property_list_changed() -> void:
	for node in _vbox.get_children():
		remove_child(node)
		node.queue_free()
	_editors.clear()

	var properties := _cue.get_property_list()
	for name in _cue._get_editor_graph_properties():
		for property in properties:
			if String(property.name) != name:
				continue

			var type := property.get(&'type', 0)
			var hint := property.get(&'hint', 0)
			var hint_text := property.get(&'hint_string', '')
			var usage := property.get(&'usage', 0)

			var editor := EditorInspector.instantiate_property_editor(_cue, type, name, hint, hint_text, usage)
			editor.draw_label = false
			editor.property_changed.connect(_on_editor_property_changed)
			editor.read_only = read_only
			editor.set_object_and_property(_cue, name)
			_vbox.add_child(editor)
			_editors[name] = editor


func _on_editor_property_changed(property: StringName, value: Variant, field: StringName, changing: bool) -> void:
	var old := _cue.get(property)
	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action('Change Cue "%s" property' % property, UndoRedo.MERGE_ENDS)
	undo_redo.add_do_property(_cue, property, value)
	undo_redo.add_undo_property(_cue, property, old)
	undo_redo.commit_action()
