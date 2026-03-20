@tool
class_name YSNScenario extends Resource

const _YSNCueBegin = preload('./cue/ysn_cue_begin.gd')

@export_storage
var _cue_begin: YSNCue:
	get:
		if _cue_begin is not _YSNCueBegin:
			_cue_begin = _YSNCueBegin.new()
		return _cue_begin

@export_storage
var _cues: Dictionary = {_cue_begin: {}}:
	set(value):
		_validate_cues(value)
		_cues = value
	get:
		return _cues


func add_cue(cue: YSNCue, position := Vector2.ZERO) -> void:
	_add_cue(cue, position)
	emit_changed()

func move_cue(cue: YSNCue, position: Vector2) -> void:
	_get_cue_data(cue)[&'position'] = position
	emit_changed()

func resize_cue(cue: YSNCue, size: Vector2) -> void:
	_get_cue_data(cue)[&'size'] = size
	emit_changed()

func remove_cue(cue: YSNCue) -> void:
	_cues.erase(cue)
	for key in _cues:
		var scue := key as YSNCue
		for output in scue.get_outputs():
			_disconnect_cue(scue, output, cue)
	cue.free()
	emit_changed()

func get_cues() -> Array[YSNCue]:
	var result: Array[YSNCue]
	result.assign(_cues.keys())
	return result

func get_cue_position(cue: YSNCue) -> Vector2:
	return _get_cue_data(cue).get(&'position', Vector2.ZERO)

func get_cue_size(cue: YSNCue) -> Vector2:
	return _get_cue_data(cue).get(&'size', Vector2.ZERO)

func connect_cue(from: YSNCue, output: StringName, to: YSNCue) -> bool:
	if not has_cue(to):
		push_error('This Cue is not owned by this Scenario.')
		return false
	var connection: Array = _get_cue_data_connection(from, output)
	if connection.has(to):
		return false
	connection.append(to)
	emit_changed()
	return true

func disconnect_cue(from: YSNCue, output: StringName, to: YSNCue) -> bool:
	if _disconnect_cue(from, output, to):
		emit_changed()
		return true
	return false

func _disconnect_cue(from: YSNCue, output: StringName, to: YSNCue) -> bool:
	var connection: Array = _get_cue_data_connection(from, output)
	if not connection.has(to):
		return false
	connection.erase(to)
	return true

func has_cue(cue: YSNCue) -> bool:
	if cue.original:
		cue = cue.original
	return _cues.has(cue)

func get_next_cues(cue: YSNCue, output: StringName) -> Array[YSNCue]:
	var result: Array[YSNCue]
	result.assign(_get_cue_data_connection(cue, output))
	for c in result:
		c._scenario = self
	return result

func _get_cue_data(cue: YSNCue) -> Dictionary:
	if cue.original:
		return _get_cue_data(cue.original)
	if not _cues.has(cue):
		push_error('Scenario does not have Cue "%s".' % cue)
		return {}
	return _cues[cue]

func _get_cue_data_connections(cue: YSNCue) -> Dictionary:
	return _get_cue_data(cue).get_or_add(&'connections', {})

func _get_cue_data_connection(cue: YSNCue, output: StringName) -> Array:
	return _get_cue_data_connections(cue).get_or_add(output, [])

func _add_cue(cue: YSNCue, position: Vector2) -> void:
	if cue is _YSNCueBegin:
		push_error('You cannot add Begin Cue manually.')
		return
	cue._scenario = self
	_cues[cue] = {&'position': position}

func _validate_cues(cues: Dictionary) -> void:
	var has_begin := false
	for key in cues.keys():
		var cue := key as YSNCue
		cue._scenario = self
		if cue is _YSNCueBegin:
			if cue == _cue_begin:
				has_begin = true
			else:
				cues.erase(cue)
				continue
	if not has_begin:
		cues[_cue_begin] = {}
