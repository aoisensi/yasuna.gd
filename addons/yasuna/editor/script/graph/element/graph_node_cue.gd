@tool
extends GraphNode

const _GraphEdit := preload('../graph_edit.gd')

var _edit: _GraphEdit
var _cue: YSNCue


func _init(cue: YSNCue, edit: _GraphEdit) -> void:
	assert(cue)
	assert(edit)
	_cue = cue
	_edit = edit

	dragged.connect(_on_dragged)
	node_selected.connect(_on_node_selected)

	_cue.script_changed.connect(_on_cue_script_changed)

	_on_cue_script_changed()


#region Signal
func _on_node_selected() -> void:
	EditorInterface.inspect_object(_cue)


func _on_dragged(from: Vector2, to: Vector2) -> void:
	_edit._draggers[_cue.id] = PackedVector2Array([from, to])
#endregion


#region Cue Signal
func _on_cue_script_changed() -> void:
	title = _cue._editor_get_title()
#endregion
