@tool
class_name YSNCueBegin
extends YSNCue

signal on_begun


func _setup() -> void:
	pass


func _editor_get_title() -> String:
	return &'Begin'


func _editor_get_category() -> String:
	return &'Debug'
