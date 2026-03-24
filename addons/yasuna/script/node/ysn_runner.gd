class_name YSNRunner extends Node

@export var auto_acts: Array[YSNScenario]

var instances: Array[YSNInstance] = []


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
	instance._queue_cue(1, &'')
	instance._run()

func _release_instance(instance: YSNInstance) -> void:
	instances.erase(instance)
