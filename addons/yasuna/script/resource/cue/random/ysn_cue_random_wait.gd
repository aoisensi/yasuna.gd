@tool
class_name YSNCueRandomWait
extends YSNCueWait

@export var min_sec := 1.0:
	set(value):
		min_sec = max(0.0, value)
		emit_changed()
	get:
		return min_sec
@export var max_sec := 3.0:
	set(value):
		max_sec = max(0.0, value)
		emit_changed()
	get:
		return max_sec


func _validate_property(property: Dictionary) -> void:
	if property.name == &'time_sec':
		property.usage = PROPERTY_USAGE_NONE


func _get_time_sec() -> float:
	return min_sec + (max_sec - min_sec) * randf()


func _get_editor_title() -> StringName:
	return &'Random Wait'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/beach.svg')


func _create_editor_custom_body(parameters: Dictionary) -> Control:
	return null
