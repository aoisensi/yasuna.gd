@tool
class_name YSNCueBegin
extends YSNCue

const EMITTER_START = &'start'

@export var begin_name := &'main':
	set(value):
		if begin_name == value:
			return
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


func _get_editor_graph_properties() -> PackedStringArray:
	return ['begin_name']


func _get_editor_node_color() -> Color:
	return Color.RED
