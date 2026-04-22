@tool
class_name YSNCueDebugButton
extends YSNCue

const EMIT_FLOW_DEBUG = &'debug'


func _received(context: YSNContext) -> void:
	pass


func _get_receive_flows() -> Array[StringName]:
	return []


func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_DEBUG]


func _get_editor_title() -> StringName:
	return 'Debug Button'


func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/arrow-right-to-arc.svg')


func _get_editor_graph_extensions() -> Array[RefCounted]:
	return [load('res://addons/yasuna/editor/script/graph/extension/ysn_graph_node_extension_debug_button.gd').new()]
