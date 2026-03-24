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
@export var _counter: int = 0

var _queue: Array[Dictionary] = []
var _running := false

func _get_states(cue: YSNCueStateful) -> Array[YSNCueStateful.State]:
	var result: Array[YSNCueStateful.State] = []
	result.assign(_states.get_or_add(cue, []))
	return result

func _get_or_create_state(cue: YSNCueStateful) -> YSNCueStateful.State:
	var states: Array = _states.get_or_add(cue, [])
	var size := states.size()
	if size == 0:
		return _create_state(cue)
	if size > 1:
		push_warning()
	return states.front()

func _create_state(cue: YSNCueStateful) -> YSNCueStateful.State:
	var state = cue._get_state_class().new()
	assert(state is YSNCueStateful.State)
	state._cue = cue
	state._instance = self
	_add_state(state)
	return state

func _remove_state(state: YSNCueStateful.State) -> void:
	var states := _states.get(state.cue, [])
	states.erase(state)
	if not states:
		_states.erase(state.cue)

func _remove_states(cue: YSNCueStateful) -> void:
	_states.erase(cue)

func _add_state(state: YSNCueStateful.State) -> void:
	_states.get_or_add(state.cue, []).append(state)

func _run() -> void:
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

func _queue_cue(cue: int, flow: StringName) -> void:
	_counter += 1
	_queue.append({
		cue = cue,
		flow = flow,
	})
