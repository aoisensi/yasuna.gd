@tool
extends YSNCue


func get_title() -> StringName:
	return &'Begin'

func _task() -> void:
	pass

func has_begin_input() -> bool:
	return false

func has_completed_output() -> bool:
	return false
