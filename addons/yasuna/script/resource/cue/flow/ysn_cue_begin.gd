@tool
class_name YSNCueBegin
extends YSNCue

@export var begin_name := &'main'


func _get_inputs() -> Array[Dictionary]:
	return []


func _perform(context: YSNContext) -> void:
	pass


func _editor_get_name() -> String:
	return &'Begin'


func _editor_get_icon() -> Texture2D:
	return load('res://addons/at-icons/node/play.svg')


func _editor_get_category() -> String:
	return &'Flow'
