extends EditorResourcePicker

var _cue: YSNCue
var _property: StringName


func _init(cue: YSNCue, property: StringName) -> void:

	custom_minimum_size = Vector2(240.0, 0.0)

	_cue = cue
	_property = property

	base_type = 'YSNScenario'

	_cue.changed.connect(_on_cue_changed)
	resource_selected.connect(_on_resource_selected)

	_on_cue_changed()

func _on_cue_changed() -> void:
	edited_resource = _cue.get(_property)

func _on_resource_selected(resource: Resource, inspect: bool) -> void:
	_cue.set(_property, resource)
