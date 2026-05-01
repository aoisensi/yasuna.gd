@tool
class_name YSNCueLock
extends YSNCueReactive

const RECEIVE_FLOW_UNLOCK = &'unlock'
const RECEIVE_FLOW_TOGGLE = &'toggle'
const RECEIVE_FLOW_LOCK = &'lock'
const EMIT_FLOW_PASSED = &'passed'
const EMIT_FLOW_BLOCKED = &'blocked'

@export var initial_unlocked := false


func _get_receive_flows() -> Array[StringName]:
	return [RECEIVE_FLOW_ENTER, RECEIVE_FLOW_UNLOCK, RECEIVE_FLOW_TOGGLE, RECEIVE_FLOW_LOCK]


func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_PASSED, EMIT_FLOW_BLOCKED]


func _get_state_class() -> Script:
	return State


func _is_ephemeral() -> bool:
	return true


func _get_editor_title() -> StringName:
	return &'Lock'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/lock.svg')


class State extends YSNCueReactive.State:
	var unlocked: bool


	func _setup(context: YSNContext) -> void:
		var cue := context.cue as YSNCueLock
		unlocked = cue.initial_unlocked


	func _evaluate(context: YSNContext) -> void:
		var cue := context.cue as YSNCueLock
		match context.flow:
			YSNCue.RECEIVE_FLOW_ENTER:
				if unlocked:
					context.emit_flow(EMIT_FLOW_PASSED)
				else:
					context.emit_flow(EMIT_FLOW_BLOCKED)
			RECEIVE_FLOW_LOCK:
				unlocked = false
			RECEIVE_FLOW_TOGGLE:
				unlocked = not unlocked
			RECEIVE_FLOW_UNLOCK:
				unlocked = true


	func _capture() -> Dictionary:
		return { unlocked = unlocked }


	func _restore(context: YSNContext, data: Dictionary) -> void:
		unlocked = data.unlocked
