@tool
class_name YSNCueKeepAlive
extends YSNCueReactive

const RECEIVE_FLOW_OPEN = &'open'


func _get_receive_flows() -> Array[StringName]:
	return [RECEIVE_FLOW_OPEN, RECEIVE_FLOW_CLOSE]


func _get_emit_flows() -> Array[StringName]:
	return []


func _get_state_class() -> Script:
	return State


class State extends YSNCueReactive.State:
	func _evaluate(context: YSNContext) -> void:
		pass


	func _capture() -> Dictionary:
		return { }


	func _restore(context: YSNContext, data: Dictionary) -> void:
		pass
