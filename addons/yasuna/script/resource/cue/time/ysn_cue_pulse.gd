@tool
class_name YSNCuePulse extends YSNCueReactive

const RECEIVE_FLOW_START = &'start'
const RECEIVE_FLOW_PAUSE = &'pause'
const RECEIVE_FLOW_RESUME = &'resume'
const EMIT_FLOW_PULSED = &'pulsed'


@export var count := -1:
	set(value):
		value = maxi(-1, value)
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


func _get_editor_title() -> StringName:
	return &'Pulse'

func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_PULSED]

func _get_receive_flows() -> Array[StringName]:
	var flows: Array[StringName] = [RECEIVE_FLOW_START, RECEIVE_FLOW_PAUSE, RECEIVE_FLOW_RESUME]
	flows.append_array(super._get_receive_flows())
	return flows

func _get_state_class() -> Script:
	return State

func _is_ephemeral() -> bool:
	return false

func _get_editor_custom_body() -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_pulse_body.gd').new(self)


class State extends YSNCueReactive.State:
	
	var _timer: Timer
	@export var counter: int

	func _evaluate(context: YSNContext) -> void:
		var cue := context.cue as YSNCuePulse
		match context.flow:
			RECEIVE_FLOW_START:
				_destroy(context)
				counter = 0
				if cue.count == 0:
					return
				_timer = Timer.new()
				context.runner.add_child(_timer, false, Node.INTERNAL_MODE_BACK)
				_timer.wait_time = cue.time_sec
				_timer.process_mode = Node.PROCESS_MODE_ALWAYS if cue.process_always else Node.PROCESS_MODE_PAUSABLE
				_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS if cue.process_in_physics else Timer.TIMER_PROCESS_IDLE
				_timer.ignore_time_scale = cue.ignore_time_scale
				_timer.timeout.connect(_pulsed.bind(context))
				_timer.start()
			RECEIVE_FLOW_PAUSE:
				if _timer:
					if not _timer.is_stopped():
						_timer.stop()
			RECEIVE_FLOW_RESUME:
				if _timer:
					if _timer.is_stopped():
						_timer.start()
			RECEIVE_FLOW_RESET:
				context.runner.remove_child(_timer)
				_timer.queue_free()
				_timer = null
			
	func _pulsed(context: YSNContext) -> void:
		context.emit_flow(EMIT_FLOW_PULSED)
		counter += 1
		var cue := context.cue as YSNCuePulse
		if counter == cue.count:
			_destroy(context)

	func _destroy(context: YSNContext) -> void:
		if _timer:
			context.runner.remove_child(_timer)
			_timer.queue_free()
			_timer = null
