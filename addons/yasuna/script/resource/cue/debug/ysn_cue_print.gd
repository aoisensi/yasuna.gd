@tool
class_name YSNCuePrint
extends YSNCue

@export() var message: String = 'hi':
	set(value):
		message = value
		emit_changed()
	get:
		return message


func _perform(context: YSNContext) -> void:
	match context.input:
		INPUT_DO:
			print(message)
			context.emit_flow(OUTPUT_THEN)


func _editor_get_name() -> String:
	return &'Print'


func _editor_get_icon() -> Texture2D:
	return load('res://addons/at-icons/node/pencil.svg')


func _editor_get_properties() -> Array[StringName]:
	return [&'message']
