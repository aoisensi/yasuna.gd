class_name YSNContext
extends RefCounted

var id: int:
	get:
		return _id
var instance: YSNInstance:
	get:
		return _instance
var scenario: YSNScenario:
	get:
		return _instance.scenario
var cue: YSNCue:
	get:
		return scenario.get_cue(id)
var flow: StringName:
	get:
		return _flow
var runner: YSNRunner:
	get:
		return instance.runner
# cue_id
var _id: int
var _instance: YSNInstance
var _flow: StringName


func _init(instance: YSNInstance, id: int, flow: StringName) -> void:
	_instance = instance
	_id = id
	_flow = flow


func emit_flow(flow: StringName) -> void:
	instance.emit_flow(id, flow)


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
