@tool
class_name YSNCueCycle extends YSNCueReactive

const MIN_FLOWS = 2
const MAX_FLOWS = 100

@export_range(MIN_FLOWS, MAX_FLOWS)
var count := MIN_FLOWS:
	set(value):
		value = clampi(value, MIN_FLOWS, MAX_FLOWS)
		if count != value:
			count = value
			emit_changed()
	get:
		return count


func _get_receive_flows() -> Array[StringName]:
	var flows: Array[StringName] = [YSNCue.RECEIVE_FLOW_ENTER]
	flows.append_array(super._get_receive_flows())
	return flows

func _get_emit_flows() -> Array[StringName]:
	return _get_number_flows(count)

func _get_state_class() -> Script:
	return State

func _get_editor_title() -> StringName:
	return &'Cycle'

func _get_editor_custom_action() -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_count_action.gd').new(self, &'count')


class State extends YSNCueReactive.State:

	@export var counted := 0

	func _evaluate(context: YSNContext) -> void:
		var cue := context.cue as YSNCueCycle
		counted %= cue.count
		counted += 1
		context.emit_flow(str(counted))
