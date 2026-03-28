@tool
class_name YSNCueSubScenario extends YSNCueStateless

@export var sub_scenario: YSNScenario:
	set(value):
		if sub_scenario != value:
			sub_scenario = value
			emit_changed()
	get:
		return sub_scenario


func _perform(context: YSNContext) -> void:
	context.runner.act(sub_scenario)

func _get_editor_title() -> StringName:
	return &'Sub Scenario'

func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/file.svg')
