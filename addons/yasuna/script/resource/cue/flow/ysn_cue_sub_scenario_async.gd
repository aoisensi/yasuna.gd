@tool
class_name YSNCueSubScenarioAsync extends YSNCueAsync

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

func _create_editor_custom_body(parameters: Dictionary) -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_scenario_body.gd').new(self, parameters.editable, &'sub_scenario')


class State extends YSNCueAsync.State:

	@export var sid: int

	func _perfome(context: YSNContext) -> void:
		var cue := context.cue as YSNCueSubScenarioAsync
		var instance := context.runner.act(cue.sub_scenario, cue.begin_name)
		sid = instance.sid
		if instance.is_finished: # when immediately scenario
			return
		await instance.finished
