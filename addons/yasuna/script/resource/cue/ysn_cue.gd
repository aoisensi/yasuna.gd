@tool
@abstract
class_name YSNCue extends Resource

const OUTPUT_STARTED = &'started'

var _runner: YSNRunner
var runner: YSNRunner:
	get:
		return _runner

var _scenario: YSNScenario
var scenario: YSNScenario:
	get:
		return _scenario

var _original: YSNCue
var original: YSNCue:
	get:
		return _original


func _action() -> void:
	task()
	emit(OUTPUT_STARTED)

func emit(output: StringName) -> void:
	for cue in scenario.get_next_cues(self, output):
		runner._cue_act.emit(cue)

@abstract
func task() -> void

func get_title() -> StringName:
	return get_class()

func get_outputs() -> Array[StringName]:
	return [OUTPUT_STARTED]

func has_output(output: StringName) -> bool:
	return get_outputs().has(output)

func get_editor_custom_body_script() -> Script:
	return null

func get_editor_custom_action_script() -> Script:
	return null

func is_editor_resizable_node() -> bool:
	return false

func _duplicate_cue(runner: YSNRunner) -> YSNCue:
	var dup: YSNCue = duplicate()
	dup._original = self
	dup._runner = runner
	dup._scenario = scenario
	assert(runner)
	assert(scenario)
	return dup
