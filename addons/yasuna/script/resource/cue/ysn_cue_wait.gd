@tool
class_name YSNCueWait extends YSNCueAsync

@export var time_sec := 1.0
@export var process_always := false
@export var process_in_physics := true
@export var ignore_time_scale := false


func task_async() -> void:
	if time_sec > 0.0:
		var timer := runner.get_tree().create_timer(time_sec, process_always, process_in_physics, ignore_time_scale)
		await timer.timeout

func get_title() -> StringName:
	return &'Wait'
