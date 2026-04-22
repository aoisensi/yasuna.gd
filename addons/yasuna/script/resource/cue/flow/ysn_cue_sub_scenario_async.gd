@tool
class_name YSNCueSubScenarioAsync
extends YSNCueAsync

@export var sub_scenario: YSNScenario:
	set(value):
		if sub_scenario != value:
			sub_scenario = value
			emit_changed()
	get:
		return sub_scenario
@export var begin_name := &'main':
	set(value):
		if begin_name != value:
			begin_name = value
			emit_changed()
	get:
		return begin_name


func _get_state_class() -> Script:
	return State


func _get_editor_title() -> StringName:
	return &'Sub Scenario Async'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/file-time.svg')


# TODO
class State extends YSNCueAsync.State:
	var sid: int


	func _perform(context: YSNContext) -> void:
		var cue := context.cue as YSNCueSubScenarioAsync
		var instance := context.runner.act(cue.sub_scenario, cue.begin_name)
		sid = instance.sid
		if not instance.is_finished: # when immediately scenario
			await instance.finished
		complete(context)


	func _capture() -> Dictionary:
		return { sid = sid }


	func _restore(context: YSNContext, data: Dictionary) -> void:
		sid = data.sid
		var instance := context.runner._instances[sid]
		if not instance.is_finished:
			await instance.finished
		complete(context)
