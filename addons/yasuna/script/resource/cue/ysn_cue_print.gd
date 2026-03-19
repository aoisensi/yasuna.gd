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
