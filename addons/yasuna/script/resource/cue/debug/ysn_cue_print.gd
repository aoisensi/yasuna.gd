@tool
class_name YSNCuePrint extends YSNCueStateless

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

func _get_editor_custom_body() -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_print_body.gd').new(self)

func _is_editor_node_resizable() -> bool:
	return true
