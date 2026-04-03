@tool
class_name YSNCueRandomChoice extends YSNCueReactive

const RECEIVE_FLOW_DICE = &'dice'

@export_range(2, 100)
var options: int = 3:
	set(value):
		value = clampi(value, 3 if avoid_repeat else 2, 100)
		if options != value:
			options = value
			emit_changed()
	get:
		return options

@export var avoid_repeat := false:
	set(value):
		if avoid_repeat != value:
			avoid_repeat = value
			if avoid_repeat and options == 2:
				options = 3
			emit_changed()
	get:
		return avoid_repeat


func _get_receive_flows() -> Array[StringName]:
	return [RECEIVE_FLOW_DICE]

func _get_emit_flows() -> Array[StringName]:
	return _get_number_flows(options)

func _get_state_class() -> Script:
	return State

func _get_editor_title() -> StringName:
	return &'Random Choice'

func _get_editor_icon() -> Texture2D:
	var path := 'res://addons/yasuna/editor/resource/icon/dice-%d.svg' % (randi() % 6 + 1)
	return load(path)

func _create_editor_custom_action(parameters: Dictionary) -> Control:
	return load('res://addons/yasuna/editor/script/graph/custom/ysn_graph_node_custom_count_action.gd').new(self, &'options')


class State extends YSNCueReactive.State:

	var _random := RandomNumberGenerator.new()
	@export var latest: int

	func _evaluate(context: YSNContext) -> void:
		var cue := context.cue as YSNCueRandomChoice
		var to := cue.options
		if cue.avoid_repeat and latest > 0:
			to -= 1
		var n := _random.randi_range(1, to)
		if cue.avoid_repeat and latest > 0:
			if n >= latest:
				n += 1
		latest = n
		context.emit_flow(str(n))
