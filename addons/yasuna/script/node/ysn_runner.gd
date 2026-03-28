class_name YSNRunner extends Node

@export var auto_acts: Array[YSNScenario]

var instances: Array[YSNInstance] = []

signal finished(scenario: YSNScenario)


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
	return instance

func _finish_instance(instance: YSNInstance) -> void:
	var scenario = instance.scenario
	instances.erase(instance)
	finished.emit(scenario)
