@tool
@abstract
class_name YSNCue extends Resource

const RECEIVE_FLOW_ENTER = &'enter'


var _id: int
var id: int:
	get:
		return _id

var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario


@abstract
func _received(context: YSNContext) -> void

@abstract
func _get_receive_flows() -> Array[StringName]

@abstract
func _get_emit_flows() -> Array[StringName]

func _get_title() -> StringName:
	return get_script().get_global_name()

func _get_editor_custom_body() -> Control:
	return null

func _get_editor_custom_action() -> Control:
	return null

func _is_editor_node_resizable() -> bool:
	return false

func _get_editor_node_color() -> Color:
	return Color.GRAY

func has_receive_flow(receiver: StringName) -> bool:
	return _get_receive_flows().has(receiver)

func has_emit_flow(emitter: StringName) -> bool:
	return _get_emit_flows().has(emitter)
