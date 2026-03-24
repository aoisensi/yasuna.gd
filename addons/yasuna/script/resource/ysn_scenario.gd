@tool
class_name YSNScenario extends Resource


@export_storage
var _cues: Dictionary = {
	1: {&'cue': YSNCueBegin.new()}
}:
	set(value):
		if _cues == value:
			return
		for id in value:
			var data = value[id]
			var cue := data.cue as YSNCue
			cue._scenario = self
			cue._id = id
			cue.changed.connect(_on_cue_changed.bind(id))
		_cues = value
	get:
		return _cues

var _cues_receive_flows: Dictionary[int, Array]
var _cues_emit_flows: Dictionary[int, Array]


func add_cue(cue: YSNCue, id: int, position := Vector2.ZERO) -> void:
	assert(cue)
	assert(not _cues.has(id))
	cue._id = id
	cue._scenario = self
	var data := {&'cue': cue}
	cue.changed.connect(_on_cue_changed.bind(id))
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
						from_node = _get_editor_node_name(emitter_id),
						from_port = from_port,
						to_node = _get_editor_node_name(receiver_id),
						to_port = to_port,
						keep_alive = false,
					})
	return result

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

func get_valid_cue_id() -> int:
	var ids := _cues.keys()
	return ids.back() + 1 if ids else 1

func remove_cue(id: int) -> void:
	_cues.erase(id)
	for cue in _cues:
		var data := _get_cue_data(cue)
		var connections := data.get(&'connections')
		if not connections:
			continue
		for emitter in connections:
			connections[emitter].erase(id)
	emit_changed()

func set_cue_position(id: int, position := Vector2.ZERO) -> void:
	_get_cue_data(id)[&'position'] = position
	emit_changed()

func set_cue_size(id: int, size := Vector2.ZERO) -> void:
	_get_cue_data(id)[&'size'] = size
	emit_changed()

func get_begin_cue() -> YSNCueBegin:
	return _cues[1]

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

static func _get_editor_node_name(id: int) -> StringName:
	return StringName('Cue_%d' % id)
