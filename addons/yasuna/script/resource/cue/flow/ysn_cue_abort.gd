@tool
class_name YSNCueAbort
extends YSNCue

const RECEIVE_FLOW_ABORT = &'abort'


func _received(context: YSNContext) -> void:
	context.instance.abort()


func _get_receive_flows() -> Array[StringName]:
	return [RECEIVE_FLOW_ABORT]


func _get_emit_flows() -> Array[StringName]:
	return []


func _get_editor_title() -> StringName:
	return &'Abort'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/alert-circle.svg')
