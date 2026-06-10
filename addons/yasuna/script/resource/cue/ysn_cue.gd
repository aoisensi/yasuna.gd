@tool
@abstract
class_name YSNCue
extends YSNElement

signal flows_changed


#region Public Method
func get_output_index(name: StringName) -> int:
	return _get_outputs().find_custom(func(item): return item.name == name)


func get_input_index(name: StringName) -> int:
	return _get_inputs().find_custom(func(item): return item.name == name)
#endregion


#region Virtual Method
func _get_inputs() -> Array[Dictionary]:
	return [{ name = 'do' }]


func _get_outputs() -> Array[Dictionary]:
	return [{ name = 'then' }]


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
#endregion
