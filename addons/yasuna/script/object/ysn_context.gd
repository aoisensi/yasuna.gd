class_name YSNContext extends RefCounted

var _id: int
var id: int:
	get:
		return _id

var _instance: YSNInstance
var instance: YSNInstance:
	get:
		return _instance

var scenario: YSNScenario:
	get:
		return _instance.scenario

var cue: YSNCue:
	get:
		return scenario.get_cue(id)

var _flow: StringName
var flow: StringName:
	get:
		return _flow

var runner: YSNRunner:
	get:
		return instance.runner


func _init(instance: YSNInstance, id: int, flow: StringName) -> void:
	_instance = instance
	_id = id
	_flow = flow

func emit_flow(flow: StringName) -> void:
	for connected in scenario.get_connected_cues(id, flow):
		instance._queue_emit(connected.cue, connected.flow)
	instance._run()

func _create_state() -> YSNCueStateful.State:
	assert(cue is YSNCueStateful)
	var state = instance._create_state(cue)
	state._setup(self)
	return state

func _get_state() -> YSNCueStateful.State:
	return instance._get_states(cue).front()

func _get_or_create_state() -> YSNCueStateful.State:
	assert(cue is YSNCueStateful)
	var states := instance._get_states(cue)
	if states.size() > 0:
		if states.size() > 1:
			push_warning()
		return states.front()
	return _create_state()

func _remove_states() -> void:
	for state in instance._get_states(cue):
		state._destroy(self)
	instance._remove_states(cue)

func _remove_state(state: YSNCueStateful.State) -> void:
	state._destroy(self)
	instance._remove_state(state)
