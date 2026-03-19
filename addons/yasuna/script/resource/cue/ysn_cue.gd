@tool
@abstract
class_name YSNCue extends Resource

const OUTPUT_STARTED = &'started'

@export_storage
var _outputs: Dictionary[StringName, Dictionary] = {}: # this sub-dictionary is Dictionary[YSNCue, null]
	set(value):
		# validation
		var valid_outputs := get_outputs()
		for output in value.keys():
			if not valid_outputs.has(output):
				value.erase(output)
		_outputs = value
	get:
		return _outputs

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

func emit(name: StringName) -> void:
	var output := _outputs.get(name, {})
	for key in output.keys():
		var cue := key as YSNCue
		runner._cue_act.emit(cue)

@abstract
func task() -> void

func get_title() -> StringName:
	return get_class()

func get_outputs() -> Array[StringName]:
	return [OUTPUT_STARTED]

func _duplicate_cue(runner: YSNRunner) -> YSNCue:
	var cue: YSNCue = self.duplicate()
	cue._original = self
	cue._runner = runner
	return cue

func connect_output(from: StringName, to: YSNCue) -> void:
	if not scenario.has_cue(to):
		push_error('This Cue %s is not owned by same Scenario.' % to)
		return
	if not _outputs.has(from):
		_outputs[from] = {}
	var _set = _outputs[from]
	_set[to] = null
	scenario.connection_changed.emit()

func disconnect_output(from: StringName, to: YSNCue) -> void:
	_outputs[from].erase(to)
	scenario.connection_changed.emit()
