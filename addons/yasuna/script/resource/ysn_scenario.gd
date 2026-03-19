@tool
class_name YSNScenario extends Resource

const _YSNCueBegin = preload('./cue/ysn_cue_begin.gd')

@export_storage
var _cue_begin: YSNCue = _YSNCueBegin.new():
	get:
		return _cue_begin

@export_storage
var _cues: Dictionary[YSNCue, Dictionary] = {
	_cue_begin: {}
}:
	set(value):
		# validation
		for cue in value.keys():
			if cue is _YSNCueBegin and cue != _cue_begin:
				value.erase(cue)
			cue._scenario = self
		if not value.has(_cue_begin):
			value[_cue_begin] = {}
		_cue_begin.scenario = self
		_cues = value
	get:
		return _cues

signal connection_changed


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
	for key in _cues.keys():
		var scue := key as YSNCue
		for output in scue.get_outputs():
			scue.disconnect_output(output, cue)
	emit_changed()

func get_cues() -> Array[YSNCue]:
	return _cues.keys()

func get_cue_position(cue: YSNCue) -> Vector2:
	return _get_dict(cue).get(&'position', Vector2.ZERO)

func get_cue_size(cue: YSNCue) -> Vector2:
	return _get_dict(cue).get(&'size', Vector2.ZERO)

func has_cue(cue: YSNCue) -> bool:
	return _cues.has(cue)

func _get_dict(cue: YSNCue) -> Dictionary:
	var dict := _cues.get(cue)
	if dict is not Dictionary:
		push_error('This scenario does not have the cue. [BUG]')
	return dict

func _add_cue(cue: YSNCue, position: Vector2) -> void:
	if cue is _YSNCueBegin:
		push_error('You cannot add Begin Cue manually.')
		return
	cue._scenario = self
	_cues[cue] = {
		&'position': position
	}
