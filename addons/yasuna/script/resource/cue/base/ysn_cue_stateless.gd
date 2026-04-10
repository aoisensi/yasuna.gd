@tool
@abstract
class_name YSNCueStateless
extends YSNCue

const EMIT_FLOW_NEXT = &'next'


@abstract
func _perform(context: YSNContext) -> void


func _received(context: YSNContext) -> void:
	if context.flow != RECEIVE_FLOW_ENTER:
		return
	_perform(context)
	context.emit_flow(EMIT_FLOW_NEXT)


func _get_receive_flows() -> Array[StringName]:
	return [RECEIVE_FLOW_ENTER]


func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_NEXT]


func _get_editor_node_color() -> Color:
	return Color.BLUE
