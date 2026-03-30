class_name YSNRunner extends Node

@export var auto_acts: Array[YSNScenario]

var _instances: Dictionary[int, YSNInstance] = {}

signal finished(scenario: YSNScenario)


func _enter_tree() -> void:
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:runner_entered', [get_instance_id(), get_path()])

func _exit_tree() -> void:
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:runner_exited', [get_instance_id()])

func _ready() -> void:
	if auto_acts:
		for scenario in auto_acts:
			if scenario:
				act.call_deferred(scenario)

func act(scenario: YSNScenario) -> YSNInstance:
	var sid := _get_valid_sid()
	var instance := YSNInstance.new(sid, self, scenario)
	_instances[sid] = instance
	instance._queue_emit(1, &'') # TODO: better begin finding
	instance._run()
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:instance_started', [instance.get_instance_id(), get_instance_id(), scenario.resource_path])
	return instance

func _finish_instance(instance: YSNInstance) -> void:
	var scenario = instance.scenario
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:instance_finished', [instance.get_instance_id()])
	_instances.erase(instance.sid)
	finished.emit(scenario)

func _get_valid_sid() -> int:
	while true:
		var id := randi()
		if id == 0:
			continue
		if not _instances.has(id):
			return id
	return 0 # unreachable
