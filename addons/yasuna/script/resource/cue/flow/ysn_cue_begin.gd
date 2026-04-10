@tool
class_name YSNCueBegin
extends YSNCue

const EMITTER_START = &'start'

@export var begin_name: StringName:
	set(value):
		if begin_name == value:
			return
		if not scenario or not scenario.has_begin_cue_name(value) or not value: # empty is allowed but disabled
			begin_name = value
			emit_changed()
	get:
		return begin_name


func _received(context: YSNContext) -> void:
	context.emit_flow(EMITTER_START)


func _get_receive_flows() -> Array[StringName]:
	return []


func _get_emit_flows() -> Array[StringName]:
	return [EMITTER_START]


func _get_editor_title() -> StringName:
	return &'Begin'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/flag.svg')


func _create_editor_custom_body(parameters: Dictionary) -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_begin_body.gd').new(self, parameters.editable)


func _get_editor_node_color() -> Color:
	return Color.RED
