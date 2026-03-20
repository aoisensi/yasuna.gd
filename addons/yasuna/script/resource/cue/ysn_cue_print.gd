@tool
class_name YSNCuePrint extends YSNCue

@export_multiline()
var message: String:
	set(value):
		message = value
		emit_changed()
	get:
		return message


func task() -> void:
	print(message)

func get_title() -> StringName:
	return &'Print'

func get_editor_custom_body_script() -> Script:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_print_body.gd')

func is_editor_resizable_node() -> bool:
	return true
