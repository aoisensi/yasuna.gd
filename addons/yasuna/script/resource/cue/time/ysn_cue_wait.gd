@tool
class_name YSNCueWait
extends YSNCueAsync

@export_range(0.0, 10.0, 0.01, 'suffix:s', 'or_greater') var time_sec := 1.0:
	set(value):
		if value < 0.0 or time_sec == value:
			return
		time_sec = value
		emit_changed()
	get:
		return time_sec
@export var process_always := false
@export var process_in_physics := true
@export var ignore_time_scale := false


func _get_time_sec() -> float:
	return time_sec


func _get_state_class() -> Script:
	return State


func _get_editor_title() -> StringName:
	return &'Wait'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/clock.svg')


func _get_editor_graph_properties() -> PackedStringArray:
	return ['time_sec']


class State extends YSNCueAsync.State:
	var _timer: SceneTreeTimer


	func _perform(context: YSNContext) -> void:
		var cue := context.cue as YSNCueWait
		var time_sec := cue._get_time_sec()
		_timer = _create_timer(context, time_sec)
		await _timer.timeout
		complete(context)


	func _create_timer(context: YSNContext, time_sec: float) -> SceneTreeTimer:
		var cue := context.cue as YSNCueWait
		var tree := context.runner.get_tree()
		return tree.create_timer(time_sec, cue.process_always, cue.process_in_physics, cue.ignore_time_scale)


	func _capture() -> Dictionary:
		return { time_left = _timer.time_left }


	func _restore(context: YSNContext, data: Dictionary) -> void:
		_timer = _create_timer(context, data.time_left)
		await _timer.timeout
		complete(context)
