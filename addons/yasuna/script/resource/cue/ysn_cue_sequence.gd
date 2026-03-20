@tool
class_name YSNCueSequence extends YSNCue

@export_range(1, 100)
var count: int = 1:
	set(value):
		count = value
		_generate_outputs()
		emit_changed()
	get:
		return count

var _outputs_cache: Array[StringName] = [&'1']


func task() -> void:
	for i in range(count):
		emit(StringName(str(i + 1)))

func get_title() -> StringName:
	return &'Sequence'

func get_outputs() -> Array[StringName]:
	if not _outputs_cache:
		_generate_outputs()
	return _outputs_cache

func _generate_outputs() -> void:
	_outputs_cache = []
	_outputs_cache.resize(count)
	for i in range(count):
		_outputs_cache[i] = StringName(str(i + 1))

func get_editor_custom_action_script() -> Script:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_sequence_action.gd')
