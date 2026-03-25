@tool
class_name YSNCueOneShot extends YSNCueReactive

const EMIT_FLOW_ONCE = &'once'


func _get_receive_flows() -> Array[StringName]:
	var flows := super._get_receive_flows()
	flows.push_front(YSNCue.RECEIVE_FLOW_ENTER)
	return flows

func _get_editor_title() -> StringName:
	return &'OneShot'

func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_ONCE]

func _get_state_class() -> Script:
	return State


class State extends YSNCueReactive.State:

	@export var evaluated := false

	func _evaluate(context: YSNContext) -> void:
		if context.flow == YSNCue.RECEIVE_FLOW_ENTER:
			if evaluated:
				return
			evaluated = true
			context.emit_flow(EMIT_FLOW_ONCE)
