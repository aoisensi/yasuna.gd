class_name YSNInstance extends Resource

var _runner: YSNRunner
var runner: YSNRunner:
	get:
		return _runner
@export var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario
@export var _states: Dictionary[YSNCueStateful, Array] = {}
@export var _counter: int = 0:
	set(value):
		_counter = value
		_check_alive()
	get:
		return _counter

var _queue: Array[Dictionary] = []
var _running := false
var _is_finished := false
var is_finished := false:
	get:
		return is_finished

signal finished


func _get_states(cue: YSNCueStateful) -> Array[YSNCueStateful.State]:
	var result: Array[YSNCueStateful.State] = []
	result.assign(_states.get_or_add(cue, []))
	return result

func _create_state(cue: YSNCueStateful) -> YSNCueStateful.State:
	if not cue._is_ephemeral():
		_counter += 1
	var state = cue._get_state_class().new()
	assert(state is YSNCueStateful.State)
	state._cue = cue
	state._instance = self
	_add_state(state)
	return state

func _remove_state(state: YSNCueStateful.State) -> void:
	var states: Array = _states.get(state.cue)
	if not states:
		return
	if states.has(state):
		states.erase(state)
		if not state.cue._is_ephemeral():
			_counter -= 1
		if not states:
			_states.erase(state.cue)

func _remove_states(cue: YSNCueStateful) -> void:
	if not cue._is_ephemeral():
		_counter -= _states.get(cue, []).size()
	_states.erase(cue)

func _add_state(state: YSNCueStateful.State) -> void:
	_states.get_or_add(state.cue, []).append(state)

func _run() -> void:
	if is_finished:
		push_warning()

	if _running:
		return

	_running = true
	while not _queue.is_empty():
		var next := _queue.pop_front()
		var cue_id: int = next.cue
		var cue := scenario.get_cue(cue_id)
		var flow: StringName = next.flow
		var context := YSNContext.new(self, cue_id, flow)
		cue._received(context)
	_running = false

	_check_alive()

func _queue_emit(cue_id: int, emit_flow: StringName) -> void:
	_queue.append({
		cue = cue_id,
		flow = emit_flow,
	})

func _check_alive() -> void:
	if _counter == 0 and not _running:
		_finish()

func _finish() -> void:
	if is_finished:
		return
	is_finished = true
	runner._finish_instance(self)
	finished.emit()
