@tool
class_name YSNScenario extends Resource

@export_storage
var _cues: Dictionary[YSNCue, Dictionary] = {}


func _init() -> void:
	if _cues.size() == 0:
		var begin := preload('./cue/ysn_cue_begin.gd').new()
		_add_cue(begin, Vector2.ZERO)
		emit_changed()

func add_cue(cue: YSNCue, position := Vector2.ZERO) -> void:
	_add_cue(cue, position)
	emit_changed()

func move_cue(cue: YSNCue, position := Vector2.ZERO) -> void:
	_get_dict(cue)[&'position'] = position
	emit_changed()

func resize_cue(cue: YSNCue, size: Vector2) -> void:
	_get_dict(cue)[&'size'] = size
	emit_changed()

func remove_cue(cue: YSNCue) -> void:
	_cues.erase(cue)

func get_cues() -> Array[YSNCue]:
	return _cues.keys()

func get_cue_position(cue: YSNCue) -> Vector2:
	return _get_dict(cue).get(&'position', Vector2.ZERO)

func get_cue_size(cue: YSNCue) -> Vector2:
	return _get_dict(cue).get(&'size', Vector2.ZERO)

func _get_dict(cue: YSNCue) -> Dictionary:
	var dict := _cues.get(cue)
	if dict is not Dictionary:
		push_error('This scenario does not have the cue. [BUG]')
	return dict

func _add_cue(cue: YSNCue, position: Vector2) -> void:
	_cues[cue] = {
		&'position': position
	}
