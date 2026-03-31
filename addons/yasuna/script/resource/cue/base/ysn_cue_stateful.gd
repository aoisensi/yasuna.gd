@tool
@abstract
class_name YSNCueStateful extends YSNCue

@abstract
func _get_state_class() -> Script

func _is_ephemeral() -> bool:
	return false


@abstract
class State extends Resource:

	@export var _cue: YSNCueStateful
	var cue: YSNCueStateful:
		get:
			return _cue

	var _instance: YSNInstance
	var instance: YSNInstance:
		get:
			return _instance

	func _setup(context: YSNContext) -> void:
		pass

	@abstract
	func _received(context: YSNContext) -> void

	func _pre_captured() -> void:
		pass

	func _destroy(context: YSNContext) -> void:
		pass
