@tool
class_name YSNCueSubScenario extends YSNCueStateless

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


func _perform(context: YSNContext) -> void:
	context.runner.act(sub_scenario, begin_name)

func _get_editor_title() -> StringName:
	return &'Sub Scenario'

func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/file.svg')

func _get_editor_custom_body() -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_scenario_body.gd').new(self, &'sub_scenario')
