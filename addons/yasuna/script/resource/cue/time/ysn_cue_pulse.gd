@tool
class_name YSNCuePulse
extends YSNCueReactive

const RECEIVE_FLOW_START = &'start'
const EMIT_FLOW_PULSED = &'pulsed'

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


func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_PULSED]


func _get_receive_flows() -> Array[StringName]:
	var flows: Array[StringName] = [RECEIVE_FLOW_START]
	flows.append_array(super._get_receive_flows())
	return flows


func _get_state_class() -> Script:
	return State


func _is_ephemeral() -> bool:
	return false


func _get_editor_title() -> StringName:
	return &'Pulse'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/bolt.svg')


func _get_editor_graph_properties() -> PackedStringArray:
	return ['time_sec']


class State extends YSNCueReactive.State:
	var _timer: Timer


	func _evaluate(context: YSNContext) -> void:
		var cue := context.cue as YSNCuePulse
		match context.flow:
			RECEIVE_FLOW_START:
				if _timer:
					return
				_create_timer(context)
				_timer.start()
			RECEIVE_FLOW_RESET:
				_destroy()


	func _create_timer(context: YSNContext) -> void:
		var cue := context.cue as YSNCuePulse
		_timer = Timer.new()
		context.runner.add_child(_timer, false, Node.INTERNAL_MODE_BACK)
		_timer.wait_time = cue.time_sec
		_timer.process_mode = Node.PROCESS_MODE_ALWAYS if cue.process_always else Node.PROCESS_MODE_PAUSABLE
		_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS if cue.process_in_physics else Timer.TIMER_PROCESS_IDLE
		_timer.ignore_time_scale = cue.ignore_time_scale
		_timer.timeout.connect(_pulsed.bind(context))


	func _pulsed(context: YSNContext) -> void:
		context.emit_flow(EMIT_FLOW_PULSED)


	func _capture() -> Dictionary:
		if _timer:
			return { time_left = _timer.time_left, running = true }
		else:
			return { running = false }


	func _restore(context: YSNContext, data: Dictionary) -> void:
		if data.running:
			var cue := context.cue as YSNCuePulse
			await context.runner.get_tree().create_timer(data.time_left, cue.process_always, cue.process_in_physics, cue.ignore_time_scale).timeout
			_create_timer(context)
			_timer.start()


	func _destroy() -> void:
		if _timer:
			_timer.stop()
			_timer.get_parent().remove_child(_timer)
			_timer.queue_free()
			_timer = null
