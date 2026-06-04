@tool
@abstract
class_name YSNCue
extends YSNElement


#region Editor
func _editor_get_name() -> String:
	return (get_script() as GDScript).get_global_name()


func _editor_get_category() -> String:
	return 'Other'


func _editor_get_icon() -> Texture2D:
	return load('res://addons/at-icons/node/circle.svg')
#endregion
