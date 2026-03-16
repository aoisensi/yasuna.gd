@tool
class_name YSNScenario extends Resource

@export_storage
var cues: Array[YSNCue] = []

@export_storage
var editor_positions: Dictionary[YSNCue, Vector2] = {}


func _init() -> void:
	if cues.size() == 0:
		var begin := preload('./cue/ysn_cue_begin.gd').new()
		_add_cue(begin, Vector2.ZERO)
		emit_changed()

func add_cue(cue: YSNCue, position := Vector2.ZERO) -> void:
	_add_cue(cue, position)
	emit_changed()

func _add_cue(cue: YSNCue, position: Vector2) -> void:
	cues.append(cue)
	editor_positions[cue] = position
