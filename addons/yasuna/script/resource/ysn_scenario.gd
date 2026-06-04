@tool
class_name YSNScenario
extends Resource

const _P_NEXT_ELEMENT_ID = &'next_element_id'

var _elements: Dictionary[int, YSNElement]
var _positions: Dictionary[int, Vector2]
var _next_element_id: int = 1


#region Property Access
func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = [
		{
			name = _P_NEXT_ELEMENT_ID,
			type = TYPE_INT,
			usage = PROPERTY_USAGE_STORAGE,
		},
	]
	for id in _elements:
		list.append(
			{
				name = 'elements/%d/element' % id,
				type = TYPE_OBJECT,
				usage = PROPERTY_USAGE_STORAGE,
			},
		)
		if _positions.has(id):
			list.append(
				{
					name = 'elements/%d/position' % id,
					type = TYPE_VECTOR2,
					usage = PROPERTY_USAGE_STORAGE,
				},
			)
	return list


func _get(property: StringName) -> Variant:
	if property == _P_NEXT_ELEMENT_ID:
		return max(_next_element_id, 1)
	var path := String(property).split('/')
	if 'elements' != path.get(0):
		return null
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
	if property == _P_NEXT_ELEMENT_ID:
		_next_element_id = value
		return true
	var path := String(property).split('/')
	if 'elements' != path.get(0):
		return false
	var id := int(path.get(1))
	if id <= 0:
		return false
	match path.get(2):
		'element':
			assert(value is YSNElement)
			value._id = id
			value._scenario = self
			_elements[id] = value
		'position':
			assert(value is Vector2)
			_positions[id] = value
		_:
			return false
	return true
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
	_elements[id] = element
	_positions[id] = position
	notify_property_list_changed()
	emit_changed()
	return id


func remove_element(id: int) -> void:
	_elements.erase(id)
	_positions.erase(id)
	notify_property_list_changed()
	emit_changed()


func get_cue(id: int) -> YSNCue:
	return get_element(id) as YSNCue


func get_element(id: int) -> YSNElement:
	return _elements.get(id)


func get_element_id(element: YSNElement) -> int:
	var key := _elements.find_key(element)
	return key if key else 0


func get_element_list() -> PackedInt32Array:
	return PackedInt32Array(_elements.keys())


func get_cue_list() -> PackedInt32Array:
	var list := _elements.keys()
	list = list.filter(func(id: int): _elements[id] is YSNCue)
	return PackedInt32Array(list)


func get_valid_element_id() -> int:
	return _next_element_id


func get_element_position(id: int) -> Vector2:
	return _positions.get(id, Vector2.ZERO)


func set_element_position(id: int, position: Vector2) -> void:
	if not _elements.has(id):
		return
	var added := not _positions.has(id)
	_positions[id] = position
	if added:
		notify_property_list_changed()
	emit_changed()
#endregion
