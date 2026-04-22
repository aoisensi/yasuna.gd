@tool
class_name YSNCueRandomWait
extends YSNCueWait

@export_range(0.0, 10.0, 0.01, 'suffix:s', 'or_greater') var min_sec := 1.0:
	set(value):
		if value < 0.0 or min_sec == value:
			return
		min_sec = clamp(value, 0.0, max_sec)
		emit_changed()
	get:
		return min_sec
@export_range(0.0, 10.0, 0.01, 'suffix:s', 'or_greater') var max_sec := 3.0:
	set(value):
		if value < 0.0 or max_sec == value:
			return
		max_sec = max(min_sec, value)
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


func _get_editor_graph_properties() -> PackedStringArray:
	return ['min_sec', 'max_sec']
