@tool
class_name YSNCueSequence
extends YSNCue

const MAX_COUNT = 16

@export_range(1, MAX_COUNT) var count: int = 1:
	set(value):
		value = clamp(value, 1, 16)
		if count != value:
			count = value
			flows_changed.emit()
	get:
		return count


func _get_outputs() -> Array[Dictionary]:
	var outputs: Array[Dictionary] = []
	for i in range(count):
		outputs.append({ name = str(i + 1) })
	return outputs


func _perform(context: YSNContext) -> void:
	match context.input:
		INPUT_DO:
			for i in range(1, count + 1):
				context.emit_flow(StringName(str(i)))


func _editor_get_name() -> String:
	return &'Sequence'


func _editor_get_icon() -> Texture2D:
	return load('res://addons/at-icons/node/badge.svg')


func _editor_get_category() -> String:
	return &'Flow'
