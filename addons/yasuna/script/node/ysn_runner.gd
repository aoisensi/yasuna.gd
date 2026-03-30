class_name YSNRunner extends Node

@export var auto_acts: Array[YSNScenario]

var instances: Array[YSNInstance] = []

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
				act(scenario)

func act(scenario: YSNScenario) -> YSNInstance:
	var instance := YSNInstance.new()
	instance._runner = self
	instance._scenario = scenario
	instances.append(instance)
	instance._queue_emit(1, &'')
	instance._run()
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:instance_started', [instance.get_instance_id(), get_instance_id(), scenario.resource_path])
	return instance

func _finish_instance(instance: YSNInstance) -> void:
	var scenario = instance.scenario
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:instance_finished', [instance.get_instance_id()])
	instances.erase(instance)
	finished.emit(scenario)
