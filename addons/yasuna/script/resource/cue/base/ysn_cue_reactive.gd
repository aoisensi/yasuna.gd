@tool
@abstract
class_name YSNCueReactive
extends YSNCueStateful

const RECEIVE_FLOW_CLOSE = &'close'
const EMIT_FLOW_CLOSED = &'closed'
const EMIT_FLOW_DONE = &'done'


func close(context: YSNContext) -> void:
	context.emit_flow(EMIT_FLOW_CLOSED)
	context._remove_states()


func _received(context: YSNContext) -> void:
	if context.flow == RECEIVE_FLOW_CLOSE:
		close(context)
		return
	var state = context._get_or_create_state()
	assert(state is YSNCueReactive.State)
	state._received(context)


func _get_receive_flows() -> Array[StringName]:
	return [RECEIVE_FLOW_CLOSE]


func _get_editor_node_color() -> Color:
	return Color.YELLOW


func _get_number_flows(n: int) -> Array[StringName]:
	var result: Array[StringName] = []
	result.resize(n)
	for i in range(n):
		result[i] = StringName(str(i + 1))
	return result


@abstract
class State extends YSNCueStateful.State:
	func close(context: YSNContext) -> void:
		(cue as YSNCueReactive).close(context)


	func _received(context: YSNContext) -> void:
		_evaluate(context)


	@abstract func _evaluate(context: YSNContext) -> void
