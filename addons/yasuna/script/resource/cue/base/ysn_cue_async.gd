@tool
@abstract
class_name YSNCueAsync extends YSNCueStateful

const EMIT_FLOW_STARTED = &'started'
const EMIT_FLOW_COMPLETED = &'completed'


func _received(context: YSNContext) -> void:
	if context.flow != RECEIVE_FLOW_ENTER:
		return
	var state := context._create_state()
	assert(state is YSNCueAsync.State)
	state._received(context)
	context.emit_flow(EMIT_FLOW_STARTED)

func _get_receive_flows() -> Array[StringName]:
	return [RECEIVE_FLOW_ENTER]

func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_STARTED, EMIT_FLOW_COMPLETED]

func _get_editor_node_color() -> Color:
	return Color.GREEN


@abstract
class State extends YSNCueStateful.State:

	func _received(context: YSNContext) -> void:
		await _perform(context)

	func complete(context: YSNContext) -> void:
		context.emit_flow(EMIT_FLOW_COMPLETED)
		context._remove_state(self)

	@abstract
	func _perform(context: YSNContext) -> void
