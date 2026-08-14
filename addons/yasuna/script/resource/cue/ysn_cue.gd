@tool
@abstract
class_name YSNCue
extends YSNElement

signal flows_changed

const INPUT_DO = &'do'
const OUTPUT_THEN = &'then'

var instance: YSNInstance:
	get:
		if not _instance:
			push_error('yasuna: stateless cue cannot access instance.')
		return _instance
var _instance: YSNInstance


#region Public Method
func get_output_index(name: StringName) -> int:
	return _get_outputs().find_custom(
		func(item):
			return item.name == name,
	)


func get_input_index(name: StringName) -> int:
	return _get_inputs().find_custom(
		func(item):
			return item.name == name,
	)
#endregion


#region Virtual Method
func _get_inputs() -> Array[Dictionary]:
	return [{ name = INPUT_DO }]


func _get_outputs() -> Array[Dictionary]:
	return [{ name = OUTPUT_THEN }]


@abstract
func _perform(context: YSNContext) -> void


func _is_stateless() -> bool:
	return false
#endregion


#region Editor
func _editor_get_name() -> String:
	return (get_script() as GDScript).get_global_name()


func _editor_get_category() -> String:
	return 'Other'


func _editor_get_icon() -> Texture2D:
	return load('res://addons/at-icons/node/circle.svg')


func _editor_get_domain() -> StringName:
	return &'info.aoisensi.yasuna'


func _editor_get_properties() -> Array[StringName]:
	return []


func _editor_create_custom_control() -> Control:
	return null
#endregion
