@tool
class_name YSNCueEvery extends YSNCueReactive

const MIN_FLOWS = 2
const MAX_FLOWS = 30

@export_range(MIN_FLOWS, MAX_FLOWS)
var flows: int = 2:
	set(value):
		value = clamp(value, MIN_FLOWS, MAX_FLOWS)
		if flows != value:
			flows = value
			emit_changed()
	get:
		return flows
	
@export var reset_when_done := true


func _get_receive_flows() -> Array[StringName]:
	var flows = _get_number_flows(flows)
	flows.append_array(super._get_receive_flows())
	return flows

func _get_emit_flows() -> Array[StringName]:
	return [EMIT_FLOW_DONE]

func _get_state_class() -> Script:
	return State

func _get_editor_title() -> StringName:
	return &'Every'

func _create_editor_custom_action(parameters: Dictionary) -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_count_action.gd').new(self, &'flows')

func _get_editor_icon() -> Texture2D:
	return load('res://addons/yasuna/editor/resource/icon/list-check.svg')


class State extends YSNCueReactive.State:

	var flags := 0

	func _evaluate(context: YSNContext) -> void:
		var flow := context.flow.to_int()
		if not flow:
			return
		var cue := context.cue as YSNCueEvery
		flags |= 1 << (flow - 1)
		if flags == (1 << cue.flows) - 1:
			context.emit_flow(EMIT_FLOW_DONE)
			if cue.reset_when_done:
				flags = 0

	func _capture() -> Dictionary:
		return {flags = flags}

	func _restore(context: YSNContext, data: Dictionary) -> void:
		flags = data.flags
