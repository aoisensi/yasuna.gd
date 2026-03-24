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
		instance._queue_cue(connected.cue, connected.flow)
	instance._run()

func create_state() -> YSNCueStateful.State:
	assert(cue is YSNCueStateful)
	return instance._create_state(cue)

func get_state() -> YSNCueStateful.State:
	return instance._get_states(cue).front()

func get_or_create_state() -> YSNCueStateful.State:
	assert(cue is YSNCueStateful)
	return instance._get_or_create_state(cue)

func remove_states() -> void:
	for state in instance._get_states(cue):
		state._destroy(self)
	instance._remove_states(cue)

func remove_state(state: YSNCueStateful.State) -> void:
	state._destroy(self)
	instance._remove_state(state)

func _release() -> void:
	instance._counter -= 1
	if not instance._counter:
		runner._release_instance(instance)
