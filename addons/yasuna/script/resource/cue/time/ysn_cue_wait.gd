@tool
class_name YSNCueWait extends YSNCueAsync

@export var time_sec := 1.0:
	set(value):
		if time_sec != value:
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

func _get_editor_custom_body() -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_wait_body.gd').new(self)


class State extends YSNCueAsync.State:

	@export var time_left: float:
		set(value):
			time_left = max(0.0, value)
		get:
			return time_left

	var _timer: SceneTreeTimer

	func _perfome(context: YSNContext) -> void:
		var cue := context.cue as YSNCueWait
		_timer = _create_timer(context)
		await _timer.timeout

	func _create_timer(context: YSNContext) -> SceneTreeTimer:
		var cue := context.cue as YSNCueWait
		var tree := context.runner.get_tree()
		var time_sec := cue._get_time_sec()
		return tree.create_timer(time_sec, cue.process_always, cue.process_in_physics, cue.ignore_time_scale)

	func _pre_captured() -> void:
		if _timer:
			time_left = _timer.time_left
