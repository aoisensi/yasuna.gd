@tool
@abstract
class_name YSNCue
extends YSNElement

signal flows_changed

var _inputs: Array[Dictionary] = []
var _outputs: Array[Dictionary] = []


#region Setup
func _init() -> void:
	if Engine.is_editor_hint():
		flows_changed.connect(_on_flows_changed)
	_setup()
	_on_flows_changed()


#region Public Method
func get_output_index(output: StringName) -> int:
	var i := 0
	for item in _outputs:
		if item.name == output:
			return i
	i += 1
	return -1


func get_input_index(input: StringName) -> int:
	var i := 0
	for item in _inputs:
		if item.name == input:
			return i
	i += 1
	return -1
#endregion


@abstract
func _setup() -> void


func _on_flows_changed() -> void:
	_inputs.clear()
	_outputs.clear()
	for item in get_signal_list():
		var name := item.name as String
		var args := item.args as Array
		if args.size() > 0 and args[0].class_name == &'YSNContext':
			_inputs.append(item)
		elif name.begins_with('on_'):
			_outputs.append(item)
#endregion


#region Editor
func _editor_get_name() -> String:
	return (get_script() as GDScript).get_global_name()


func _editor_get_category() -> String:
	return 'Other'


func _editor_get_icon() -> Texture2D:
	return load('res://addons/at-icons/node/circle.svg')
#endregion
