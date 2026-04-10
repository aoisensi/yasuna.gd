@tool
@abstract
class_name YSNCue
extends Resource

const RECEIVE_FLOW_ENTER = &'enter'

var id: int:
	get:
		return _id
var scenario: YSNScenario:
	get:
		return _scenario
var _id: int
var _scenario: YSNScenario


func has_receive_flow(receiver: StringName) -> bool:
	return _get_receive_flows().has(receiver)


func has_emit_flow(emitter: StringName) -> bool:
	return _get_emit_flows().has(emitter)


@abstract
func _received(context: YSNContext) -> void


@abstract
func _get_receive_flows() -> Array[StringName]


@abstract
func _get_emit_flows() -> Array[StringName]


func _get_editor_title() -> StringName:
	return get_script().get_global_name()


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/circle.svg')


func _create_editor_custom_body(parameters: Dictionary) -> Control:
	return null


func _create_editor_custom_action(parameters: Dictionary) -> Control:
	return null


func _is_editor_node_resizable() -> bool:
	return false


func _get_editor_node_color() -> Color:
	return Color.GRAY
