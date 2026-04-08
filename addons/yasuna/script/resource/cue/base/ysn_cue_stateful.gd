@tool
@abstract
class_name YSNCueStateful extends YSNCue

@abstract
func _get_state_class() -> Script

func _is_ephemeral() -> bool:
	return false


@abstract
class State extends RefCounted:

	var _cue_id: int
	var cue_id:
		get:
			return _cue_id

	var cue: YSNCueStateful:
		get:
			return _instance.scenario.get_cue(_cue_id)

	var _instance: YSNInstance
	var instance: YSNInstance:
		get:
			return _instance

	func _setup(context: YSNContext) -> void:
		pass

	@abstract
	func _received(context: YSNContext) -> void

	@abstract
	func _capture() -> Dictionary

	@abstract
	func _restore(context: YSNContext, data: Dictionary) -> void

	func _destroy() -> void:
		pass
