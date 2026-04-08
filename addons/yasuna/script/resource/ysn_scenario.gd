@tool
class_name YSNScenario extends Resource

@export var title: String = '':
	set(value):
		if title != value:
			title = value
			emit_changed()
	get:
		return title

var _begin_cues: Dictionary[StringName, int] = {}

@export_storage
var _cues: Dictionary = _initial_cues():
	set(value):
		for id in value:
			var data = value[id]
			var cue := data.cue as YSNCue
			cue._scenario = self
			cue._id = id
			cue.changed.connect(_on_cue_changed.bind(id))
			if cue is YSNCueBegin:
				_begin_cues[cue.begin_name] = id
		_cues = value
	get:
		return _cues

var _cues_receive_flows: Dictionary[int, Array]
var _cues_emit_flows: Dictionary[int, Array]


func add_cue(cue: YSNCue, id: int, position := Vector2.ZERO) -> void:
	assert(cue)
	assert(not _cues.has(id))
	assert(not cue.scenario)
	assert(id <= 0)
	cue._scenario = self
	cue._id = id
	var data := {&'cue': cue}
	cue.changed.connect(_on_cue_changed.bind(id))
	if cue is YSNCueBegin:
		_begin_cues[cue.begin_name] = id
	if position:
		data.position = position
	_cues[id] = data
	_on_cue_changed(id)
	emit_changed()

func connect_cues(emitter_id: int, emit_flow: StringName, receiver_id: int, receive_flow: StringName) -> Error:
	var data := _get_cue_data(emitter_id)
	if not data.cue.has_emit_flow(emit_flow):
		return FAILED
	if not get_cue(receiver_id).has_receive_flow(receive_flow):
		return FAILED
	var connections: Dictionary = data.get_or_add(&'connections', {}).get_or_add(emit_flow, {})
	var c: Array = connections.get_or_add(receiver_id, [])
	if c.has(receive_flow):
		return FAILED
	c.append(receive_flow)
	emit_changed()
	return OK

func disconnect_cues(emitter_id: int, emit_flow: StringName, receiver_id := -1, receive_flow := &'') -> void:
	var data := _get_cue_data(emitter_id)
	if not data.cue.has_emit_flow(emit_flow):
		return
	var connections := data.get(&'connections')
	if not connections:
		return
	if receiver_id == -1:
		if connections.erase(emit_flow):
			emit_changed()
		return
	var connection: Dictionary = connections.get(emit_flow)
	if not connection:
		return
	if not receive_flow:
		if connection.erase(receiver_id):
			emit_changed()
		return
	var c: Array = connection.get(receiver_id)
	if not c:
		return
	if c.has(receive_flow):
		c.erase(receive_flow)
		emit_changed()

func get_cue(id: int) -> YSNCue:
	var data := _cues.get(id)
	if not data:
		return null
	return data.cue

func get_cue_connections() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for emitter_id in get_cue_list():
		var connections := _get_cue_data(emitter_id).get_or_add(&'connections', {})
		for emit_flow in connections:
			var from_port = get_cue(emitter_id)._get_emit_flows().find(emit_flow)
			if from_port < 0:
				continue
			var connection: Dictionary = connections[emit_flow]
			for receiver_id in connection:
				for receive_flow in connection[receiver_id]:
					var to_port = get_cue(receiver_id)._get_receive_flows().find(receive_flow)
					if to_port < 0:
						continue
					result.append({
						from_node = StringName(str(emitter_id)),
						from_port = from_port,
						to_node = StringName(str(receiver_id)),
						to_port = to_port,
						keep_alive = false,
					})
	return result
## [code][{ cue: int, flow: StringName }][/code]
func get_connected_cues(emitter_id: int, emit_flow: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var data = _get_cue_data(emitter_id)
	var connections: Dictionary = data.get(&'connections', {}).get(emit_flow, {})
	for receiver_id in connections:
		for flow in connections[receiver_id]:
			result.append({
				cue = receiver_id,
				flow = flow,
			})
	return result

func get_cue_list() -> PackedInt32Array:
	return PackedInt32Array(_cues.keys())

func get_cue_position(id: int) -> Vector2:
	return _get_cue_data(id).get(&'position', Vector2.ZERO)

func get_cue_size(id: int) -> Vector2:
	return _get_cue_data(id).get(&'size', Vector2.ZERO)

func get_valid_cue_id() -> int: # maybe bad code
	if _cues.is_empty():
		return 1
	var ids := _cues.keys()
	var id := ids.back()
	while _cues.has(id):
		id += 1
	return id

func remove_cue(id: int) -> bool:
	if not _cues.has(id):
		return false
	
	var cue := get_cue(id)
	if cue is YSNCueBegin and cue.begin_name == &'main':
		return false

	for cue_id in _cues:
		var data := _get_cue_data(cue_id)
		var connections := data.get(&'connections')
		if not connections:
			continue
		for emitter in connections:
			connections[emitter].erase(id)
	cue.changed.disconnect(_on_cue_changed.bind(id))
	_cues.erase(id)
	emit_changed()
	return true

func find_cue_id(cue: YSNCue) -> int:
	for id in _cues:
		var data: Dictionary = _cues[id]
		if data.cue == cue:
			return id
	return 0

func set_cue_position(id: int, position := Vector2.ZERO) -> void:
	_get_cue_data(id)[&'position'] = position
	emit_changed()

func set_cue_size(id: int, size := Vector2.ZERO) -> void:
	_get_cue_data(id)[&'size'] = size
	emit_changed()

func get_begin_cue(begin_name := &'main') -> int:
	return _begin_cues.get(begin_name)

func get_begin_cue_names() -> Array[StringName]:
	return _begin_cues.keys()

func get_valid_begin_cue_name() -> StringName:
	var i := 0
	var name := &''
	while true:
		name = StringName('begin_%d' % i)
		if not has_begin_cue_name(name):
			break
	return name

func has_begin_cue_name(name: StringName) -> bool:
	return _begin_cues.has(name)

func _on_cue_changed(cue_id: int) -> void:
	var cue := get_cue(cue_id)

	var old_emit_flows := _cues_emit_flows.get(cue_id, [])
	var now_emit_flows := cue._get_emit_flows()
	for emit_flow in old_emit_flows:
		if not now_emit_flows.has(emit_flow):
			disconnect_cues(cue_id, emit_flow)
	_cues_emit_flows[cue_id] = now_emit_flows

	var old_receive_flows := _cues_receive_flows.get(cue_id, [])
	var now_receive_flows := cue._get_receive_flows()
	for receive_flow in old_receive_flows:
		if not now_receive_flows.has(receive_flow):
			_disconnect_cues_from_receiver(cue_id, receive_flow)
	_cues_receive_flows[cue_id] = now_receive_flows

func _disconnect_cues_from_receiver(receiver_id: int, receive_flow: StringName) -> void:
	var disconnected := false
	for emitter_id in get_cue_list():
		var data := _get_cue_data(emitter_id)
		var connections: Dictionary = data.get(&'connections', {})
		for emit_flow in connections:
			var connection := connections.get(emit_flow, {})
			var c: Array = connection.get(receiver_id, [])
			if c.has(receive_flow):
				c.erase(receive_flow)
				disconnected = true
	if disconnected:
		emit_changed()

func _get_cue_data(id: int) -> Dictionary:
	var data := _cues.get(id)
	assert(data)
	return data

func _initial_cues() -> Dictionary:
	var cue := YSNCueBegin.new()
	cue._scenario = self
	cue._id = 1
	cue.begin_name = &'main'
	return {1: {cue = cue}}
