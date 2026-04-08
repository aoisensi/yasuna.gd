class_name YSNInstance extends Resource


var _runner: YSNRunner
var runner: YSNRunner:
	get:
		return _runner

@export var _sid: int
var sid: int:
	get:
		return _sid

@export var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario

@export_storage
var _states: Dictionary[int, Array] = {}

@export var _counter: int = 0:
	set(value):
		_counter = value
		_check_alive()
	get:
		return _counter

@export var _is_canceled := false

var _queue: Array[Dictionary] = []
var _running := false
var _is_finished := false
var is_finished: bool:
	get:
		return _is_finished

signal finished


func _setup(sid: int, runner: YSNRunner, scenario: YSNScenario) -> void:
	_sid = sid
	_runner = runner
	_scenario = scenario

func _get_states(cue: YSNCueStateful) -> Array[YSNCueStateful.State]:
	var result: Array[YSNCueStateful.State] = []
	result.assign(_states.get_or_add(cue.id, []))
	return result

func _create_state(cue: YSNCueStateful) -> YSNCueStateful.State:
	if not cue._is_ephemeral():
		_counter += 1
	var state = cue._get_state_class().new()
	assert(state is YSNCueStateful.State)
	state._cue_id = cue.id
	state._instance = self
	_add_state(state)
	return state

func _remove_state(state: YSNCueStateful.State) -> void:
	var states: Array = _states.get(state.cue.id)
	if not states:
		return
	if states.has(state):
		states.erase(state)
		if not state.cue._is_ephemeral():
			_counter -= 1
		if not states:
			_states.erase(state.cue.id)

func _remove_states(cue: YSNCueStateful) -> void:
	if not cue._is_ephemeral():
		_counter -= _states.get(cue.id, []).size()
	_states.erase(cue.id)

func _add_state(state: YSNCueStateful.State) -> void:
	_states.get_or_add(state.cue.id, []).append(state)

func _run() -> void:
	if is_finished:
		push_warning()
		return

	if _running:
		return

	_running = true
	while not _queue.is_empty():
		var next := _queue.pop_front()
		var cue_id: int = next.cue
		var cue := scenario.get_cue(cue_id)
		assert(cue)
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

func _begin(begin_name: StringName) -> void:
	assert(begin_name)
	var id := scenario.get_begin_cue(begin_name)
	if id <= 0:
		push_error()
		return
	_queue_emit(id, &'')
	_run()

func _check_alive() -> void:
	if _counter == 0 and not _running:
		_finish()

func _finish() -> void:
	if is_finished:
		return
	_is_finished = true
	runner._finish_instance(self)
	finished.emit()

func _capture() -> Dictionary:
	var states: Dictionary = {}
	var result: Dictionary = {
		sid = sid,
		scenario = scenario.resource_path,
		states = states,
	}
	for cue_id in _states:
		for state in _states[cue_id]:
			var data = state._capture()
			states.get_or_add(str(cue_id), []).append(data)
	return result

func _restore(data: Dictionary) -> void:
	for cue_id_str in data:
		var cue_id = int(cue_id_str)
		var cue := scenario.get_cue(cue_id) as YSNCueStateful
		for d in data[cue_id_str]:
			var state := _create_state(cue)
			var context := YSNContext.new(self, cue_id, &'')
			state._restore(context, d)

func _abort() -> void:
	_is_canceled = true

	for states in _states.values():
		for state in states:
			state._destroy()

	runner._finish_instance(self)
