@tool
@abstract
class_name YSNCueStateful extends YSNCue

@abstract
func _get_state_class() -> Script


@abstract
class State extends Resource:

	@export var _cue: YSNCue
	var cue: YSNCue:
		get:
			return _cue

	var _instance: YSNInstance
	var instance: YSNInstance:
		get:
			return _instance


	@abstract
	func _received(context: YSNContext) -> void

	func _destroy(context: YSNContext) -> void:
		pass
