@tool
class_name YSNCuePrint
extends YSNCue

@export_multiline() var message: String = 'hi'


func _perform(context: YSNContext) -> void:
	match context.input:
		INPUT_DO:
			print(message)
			context.emit_flow(OUTPUT_THEN)


func _editor_get_title() -> String:
	return &'Print'


func _editor_get_icon() -> Texture2D:
	return load('res://addons/at-icons/node/pencil.svg')
