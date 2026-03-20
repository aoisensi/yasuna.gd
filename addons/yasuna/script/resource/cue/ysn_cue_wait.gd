@tool
class_name YSNCueWait extends YSNCueAsync

@export var time_sec := 1.0:
	set(value):
		time_sec = value
		emit_changed()
	get:
		return time_sec
@export var process_always := false
@export var process_in_physics := true
@export var ignore_time_scale := false


func task_async() -> void:
	if time_sec > 0.0:
		var timer := runner.get_tree().create_timer(time_sec, process_always, process_in_physics, ignore_time_scale)
		await timer.timeout

func get_title() -> StringName:
	return &'Wait'

func get_editor_custom_body_script() -> Script:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_wait_body.gd')
