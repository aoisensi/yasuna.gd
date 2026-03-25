class_name YSNRunner extends Node

@export var auto_acts: Array[YSNScenario]

var instances: Array[YSNInstance] = []

signal instance_released(scenario: YSNScenario)


func _ready() -> void:
	if auto_acts:
		for scenario in auto_acts:
			if scenario:
				act(scenario)

func act(scenario: YSNScenario) -> void:
	var instance := YSNInstance.new()
	instance._runner = self
	instance._scenario = scenario
	instances.append(instance)
	instance._queue_emit(1, &'')
	instance._run()

func _release_instance(instance: YSNInstance) -> void:
	var scenario = instance.scenario
	instances.erase(instance)
	instance_released.emit(scenario)
