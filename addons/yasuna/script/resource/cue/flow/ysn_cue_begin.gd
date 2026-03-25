@tool
class_name YSNCueBegin extends YSNCue

const EMITTER_START = &'start'


func _received(context: YSNContext) -> void:
	context.emit_flow(EMITTER_START)
	context._release()

func _get_receive_flows() -> Array[StringName]:
	return []
	
func _get_emit_flows() -> Array[StringName]:
	return [EMITTER_START]

func _get_editor_title() -> StringName:
	return &'Begin'

func _get_editor_node_color() -> Color:
	return Color.RED
