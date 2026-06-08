@tool
class_name YSNCuePrint
extends YSNCue

signal print(context: YSNContext)
signal on_printed

@export var message: String = 'hi'


func _setup() -> void:
	print.connect(_on_print)


func _on_print(context: YSNContext) -> void:
	print(message)
	on_printed.emit()


func _editor_get_title() -> String:
	return &'Print'
