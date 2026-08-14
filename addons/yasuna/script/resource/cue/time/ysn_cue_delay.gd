@tool
class_name YSNCueDelay
extends YSNCue

@export_range(0.0, 10.0) var time_sec: float:
	set(value):
		time_sec = max(0.0, value)
		emit_changed()
	get:
		return time_sec


func _perform(context: YSNContext) -> void:
	await context.runner.get_tree().create_timer(time_sec).timeout
	context.emit_flow(OUTPUT_THEN)


func _editor_get_name() -> String:
	return 'Delay'


func _editor_get_properties() -> Array[StringName]:
	return [&'time_sec']
