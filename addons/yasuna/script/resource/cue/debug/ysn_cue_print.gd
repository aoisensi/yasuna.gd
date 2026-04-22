@tool
class_name YSNCuePrint
extends YSNCueStateless

@export_multiline()
var message: String:
	set(value):
		if message != value:
			message = value
			emit_changed()
	get:
		return message


func _perform(context: YSNContext) -> void:
	print(message)


func _get_editor_title() -> StringName:
	return &'Print'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/pencil.svg')


func _get_editor_graph_properties() -> PackedStringArray:
	return ['message']


func _is_editor_node_resizable() -> bool:
	return true
