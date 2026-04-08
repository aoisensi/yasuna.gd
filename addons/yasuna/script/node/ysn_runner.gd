class_name YSNRunner extends Node

@export var auto_acts: Array[YSNRunnerAutoAct] = []

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
		_auto_acts.call_deferred()

func _auto_acts() -> void:
	for a in auto_acts:
		act(a.scenario, a.begin_name)

func act(scenario: YSNScenario, begin_name := &'main') -> YSNInstance:
	var sid := _get_valid_sid()
	var instance := YSNInstance.new()
	instance._setup(sid, self, scenario)
	_instances[sid] = instance
	instance._begin(begin_name)

	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:instance_started', [instance.get_instance_id(), get_instance_id(), scenario.resource_path])
	return instance

func capture() -> Dictionary:
	var instances: Dictionary = {}
	var result: Dictionary = {instances = instances}
	for sid in _instances:
		var instance := _instances[sid]
		instances[str(sid)] = instance._capture()
	return result

func restore(data: Dictionary) -> void:
	var instances: Dictionary = data.instances
	assert(instances)

	abort_all()

	for sid_str in instances:
		var sid := int(sid_str)
		var instance := YSNInstance.new()
		var scenario := load(instances[sid_str].scenario)
		assert(scenario is YSNScenario)
		instance._setup(sid, self, scenario)
		instance._restore(instances[sid_str].states)
		_instances[sid] = instance

func abort_all() -> void:
	for sid in _instances:
		var instance := _instances[sid]
		instance._abort()

	_instances.clear()

func _finish_instance(instance: YSNInstance) -> void:
	var scenario = instance.scenario
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:instance_finished', [instance.get_instance_id()])
	_instances.erase(instance.sid)
	finished.emit(scenario)

func _get_valid_sid() -> int:
	var id := 0
	while true:
		var h := int(randi()) & 0x7fffffff
		var l := int(randi()) & 0xffffffff
		id = (h << 32) | l
		if id != 0 or not _instances.has(id):
			break
		# ultra jackpot
	return id
