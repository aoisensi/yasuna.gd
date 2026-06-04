@tool
extends GraphNode

var _cue: YSNCue


func _init(cue: YSNCue) -> void:
	assert(cue)
	_cue = cue

	dragged.connect(_on_dragged)
	node_selected.connect(_on_node_selected)

	_cue.script_changed.connect(_on_cue_script_changed)

	_on_cue_script_changed()


#region Signal
func _on_node_selected() -> void:
	EditorInterface.inspect_object(_cue)


func _on_dragged(from: Vector2, to: Vector2) -> void:
	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.add_do_method(_cue.scenario, &'set_element_position', _cue.id, to)
	undo_redo.add_undo_method(_cue.scenario, &'set_element_position', _cue.id, from)
#endregion


#region Cue Signal
func _on_cue_script_changed() -> void:
	title = _cue._editor_get_title()
#endregion
