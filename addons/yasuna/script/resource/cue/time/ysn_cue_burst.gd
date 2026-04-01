@tool
class_name YSNCueBurst extends YSNCueAsync

const EMIT_FLOW_BURSTED = &'bursted'


@export_range(1, 100)
var count := 3:
	set(value):
		value = maxi(1, value)
		if count != value:
			count = value
			emit_changed()
	get:
		return count

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


func _get_emit_flows() -> Array[StringName]:
	var flows := super._get_emit_flows()
	flows.insert(1, EMIT_FLOW_BURSTED)
	return flows

func _get_state_class() -> Script:
	return State

func _get_editor_title() -> StringName:
	return &'Burst'

func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/dots.svg')

func _get_editor_custom_body() -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_burst_body.gd').new(self)


class State extends YSNCueAsync.State:

	@export var counter := 0
	@export var time_left: float

	var _timer: Timer

	func _perfome(context: YSNContext) -> void:
		var cue := context.cue as YSNCueBurst
		if cue.count == 0:
			return
		_timer = Timer.new()
		context.runner.add_child(_timer, false, Node.INTERNAL_MODE_BACK)
		_timer.process_mode = Node.PROCESS_MODE_ALWAYS if cue.process_always else Node.PROCESS_MODE_PAUSABLE
		_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS if cue.process_in_physics else Timer.TIMER_PROCESS_IDLE
		_timer.ignore_time_scale = cue.ignore_time_scale
		_timer.start(cue.time_sec)
		while true:
			context.emit_flow(EMIT_FLOW_BURSTED)
			counter += 1
			if counter >= cue.count:
				_timer.stop()
				return
			await _timer.timeout

	func _destroy() -> void:
		if _timer:
			_timer.get_parent().remove_child(_timer)
			_timer.queue_free()
			_timer = null

	func _capturing() -> void:
		if _timer:
			time_left = _timer.time_left
