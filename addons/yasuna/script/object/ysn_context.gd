class_name YSNContext
extends RefCounted

var id: int:
	get:
		return _id
var instance: YSNInstance:
	get:
		return _instance
var input: StringName:
	get:
		return _input
var args: Array:
	get:
		return _args
var scenario: YSNScenario:
	get:
		return instance.scenario
var _id: int
var _instance: YSNInstance
var _input: StringName
var _args: Array


func _init(instance: YSNInstance, id: int, input: StringName, args := []) -> void:
	assert(instance)
	assert(id)
	assert(input)
	_instance = instance
	_id = id
	_input = input
	_args = args


func emit_flow(output: StringName) -> void:
	instance._emit_flow(id, output)
