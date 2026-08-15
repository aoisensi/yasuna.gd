@tool
class_name YSNScenario
extends Resource

var _connections: Dictionary[String, String]
var _elements: Dictionary[int, YSNElement]
var _positions: Dictionary[int, Vector2]
var _next_element_id: int = 1

#region Property Access
func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = [
		{ name = 'next_element_id', type = TYPE_INT, usage = PROPERTY_USAGE_STORAGE },
	]
	for id in _elements:
		list.append_array(
			[
				{
					name = 'elements/%d/element' % id,
					type = TYPE_OBJECT,
					usage = PROPERTY_USAGE_STORAGE,
				},
				{
					name = 'elements/%d/position' % id,
					type = TYPE_VECTOR2,
					usage = PROPERTY_USAGE_STORAGE,
				},
			],
		)
	list.append(
		{ name = 'connections', type = TYPE_PACKED_STRING_ARRAY, usage = PROPERTY_USAGE_STORAGE },
	)
	return list


func _get(property: StringName) -> Variant:
	match property:
		&'next_element_id':
			return max(_next_element_id, 1)
		&'connections':
			var connections := PackedStringArray()
			for from in _connections:
				var to := _connections[from]
				connections.append('%s/%s' % [from, to])
			return connections

	var path := String(property).split('/')
	match path.get(0):
		'elements':
			var id := int(path.get(1))
			if id <= 0:
				return null
			match path.get(2):
				'element':
					return _elements.get(id)
				'position':
					return _positions.get(id, Vector2.ZERO)
	return null


func _set(property: StringName, value: Variant) -> bool:
	match property:
		&'next_element_id':
			_next_element_id = value
			return true
		&'connections':
			for cs in value as PackedStringArray:
				var c := cs.split('/')
				assert(c.size() == 4)
				_connect(int(c[0]), c[1], int(c[2]), c[3])
			return true

	var path := String(property).split('/')
	match path.get(0):
		'elements':
			var id := int(path.get(1))
			if id <= 0:
				return false
			match path.get(2):
				'element':
					if value is not YSNElement:
						return false
					value._id = id
					value._scenario = self
					_elements[id] = value
					return true
				'position':
					if value is not Vector2:
						return false
					_positions[id] = value
					return true
	return false
#endregion

#region Public Methods
func add_element(element: YSNElement, position := Vector2.ZERO, id := -1) -> int:
	assert(element)
	if id == 0:
		push_error('yasuna: element id 0 is not allowed.')
		return 0
	if id < 0:
		id = _next_element_id
	if id > _next_element_id:
		push_error('yasuna: element id cannot become greater than valid id.')
		return 0
	if _elements.has(id):
		push_error('yasuna: element id %d is already used.' % id)
		return 0
	if id == _next_element_id:
		_next_element_id += 1
	element._scenario = self
	element._id = id
	_positions[id] = position
	_elements[id] = element
	notify_property_list_changed()
	emit_changed()
	return id


func remove_element(id: int) -> void:
	_elements.erase(id)
	_validate_connections()
	notify_property_list_changed()
	emit_changed()


func connect_cue(from_cue: int, from_flow: StringName, to_cue: int, to_flow: StringName) -> Error:
	_connect(from_cue, from_flow, to_cue, to_flow)
	emit_changed()
	return OK


func disconnect_cue(from_cue: int, from_flow: StringName, to_cue: int, to_flow: StringName) -> void:
	_disconnect(from_cue, from_flow, to_cue, to_flow)
	_validate_connections()
	emit_changed()


func get_cue(id: int) -> YSNCue:
	return get_element(id) as YSNCue


func get_element(id: int) -> YSNElement:
	var element := _elements.get(id)
	if element:
		return element
	push_error()
	return null


func get_element_id(element: YSNElement) -> int:
	var key := _elements.find_key(element)
	return key if key else 0


func get_element_list() -> PackedInt32Array:
	return PackedInt32Array(_elements.keys())


func get_cue_list() -> PackedInt32Array:
	var list := _elements.keys()
	list = list.filter(
		func(id: int):
			return _elements[id] is YSNCue,
	)
	return PackedInt32Array(list)


func get_valid_element_id() -> int:
	return _next_element_id


func get_element_position(id: int) -> Vector2:
	return _positions.get(id, Vector2.ZERO)


func set_element_position(id: int, position: Vector2) -> void:
	_positions[id] = position
	emit_changed()
#endregion

func _get_connections() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	_iter_connections(
		func(from_id: int, from_flow: StringName, to_id: int, to_flow: StringName) -> void:
			result.append(
				{
					from_node = StringName(str(from_id)),
					from_port = (get_cue(from_id) as YSNCue).get_output_index(from_flow),
					to_node = StringName(str(to_id)),
					to_port = (get_cue(to_id) as YSNCue).get_input_index(to_flow),
					keep_alive = true,
				},
			),
	)
	return result


func _iter_connections(f: Callable) -> void:
	for from in _connections:
		var to := _connections[from]
		var froms := from.split('/')
		var tos := to.split('/')
		f.call(int(froms[0]), froms[1], int(tos[0]), tos[1])


func _connect(from_cue: int, from_flow: StringName, to_cue: int, to_flow: StringName) -> bool:
	var key := '%d/%s' % [from_cue, from_flow]
	if _connections.has(key):
		return false
	var value := '%d/%s' % [to_cue, to_flow]
	_connections[key] = value
	return true


func _disconnect(from_cue: int, from_flow: StringName, to_cue: int, to_flow: StringName) -> bool:
	var key := '%d/%s' % [from_cue, from_flow]
	var value := '%d/%s' % [to_cue, to_flow]
	if _connections.get(key) != value:
		return false
	return _connections.erase(key)


func _validate_connections() -> void:
	var froms: Array[String] = _connections.keys()
	for from in froms:
		var to := _connections[from]
		var from_s := from.split('/')
		var to_s := to.split('/')
		var from_id := int(from_s[0])
		var to_id := int(to_s[1])
		if _elements.get(from_id) is not YSNCue or _elements.get(to_id) is not YSNCue:
			_connections.erase(from)
