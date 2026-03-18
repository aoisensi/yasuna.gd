@tool
@abstract
class_name YSNCue extends Resource

@abstract
func _task() -> void

func get_custom_outputs() -> Array[StringName]:
	return []

func has_started_output() -> bool:
	return true

func has_completed_output() -> bool:
	return true

func has_begin_input() -> bool:
	return true

func get_custom_control() -> Control:
	return null
