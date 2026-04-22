class_name YSNRunner
extends Node

signal completed(scenario: YSNScenario)
signal aborted(scenario: YSNScenario)
signal closed(scenario: YSNScenario)

@export var auto_acts: Array[YSNRunnerAutoAct] = []

var _instances: Dictionary[int, YSNInstance] = { }


func _enter_tree() -> void:
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:runner_entered', [get_instance_id(), get_path()])
		EngineDebugger.register_message_capture('yasuna', _debugger_message_captured)


func _ready() -> void:
	if auto_acts:
		_auto_acts.call_deferred()


func _exit_tree() -> void:
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:runner_exited', [get_instance_id()])


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
	var instances: Dictionary = { }
	var result: Dictionary = { instances = instances }
	for sid in _instances:
		var instance := _instances[sid]
		instances[str(sid)] = instance._capture()
	return result


func restore(data: Dictionary) -> Array[YSNInstance]:
	var instances: Dictionary = data.instances
	assert(instances)

	abort_all()

	var result: Array[YSNInstance] = []

	for sid_str in instances:
		var sid := int(sid_str)
		var instance := YSNInstance.new()
		var scenario := load(instances[sid_str].scenario)
		assert(scenario is YSNScenario)
		instance._setup(sid, self, scenario)
		_instances[sid] = instance
		result.append(instance)

	for sid_str in instances:
		var sid := int(sid_str)
		_instances[sid]._restore(instances[sid_str].states)

	return result


func abort_all() -> void:
	for sid in _instances:
		var instance := _instances[sid]
		instance.abort()


func _auto_acts() -> void:
	for a in auto_acts:
		act(a.scenario, a.begin_name)


func _close_instance(instance: YSNInstance) -> void:
	var scenario = instance.scenario
	if EngineDebugger.is_active():
		EngineDebugger.send_message('yasuna:instance_closed', [instance.get_instance_id()])
	_instances.erase(instance.sid)
	closed.emit(scenario)


func _get_valid_sid() -> int:
	var id := 0
	while true:
		var h := int(randi()) & 0x7fffffff
		var l := int(randi()) & 0xffffffff
		id = (h << 32) | l
		if id != 0 and not _instances.has(id):
			break
		# ultra jackpot
	return id


func _debugger_message_captured(message: String, data: Array) -> bool:
	match message:
		'cue_flow_emit':
			return _debug_cue_flow_emitted(data[0], data[1], data[2])
	return false


func _debug_cue_flow_emitted(instance_id: int, cue_id: int, emit_flow: StringName) -> bool:
	for i in _instances.values():
		var instance := i as YSNInstance
		if instance.get_instance_id() != instance_id:
			continue
		var context := YSNContext.new(instance, cue_id, &'')
		context.emit_flow(emit_flow)
		return true
	return false
