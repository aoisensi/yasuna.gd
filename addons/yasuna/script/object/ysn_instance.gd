class_name YSNInstance
extends RefCounted

var runner: YSNRunner:
	get:
		return _runner
var scenario: YSNScenario:
	get:
		return _scenario
var _runner: YSNRunner
var _scenario: YSNScenario
var _cues: Dictionary[int, YSNCue] = { }
var _begins: Dictionary[StringName, int]


func _init(runner: YSNRunner, scenario: YSNScenario) -> void:
	assert(runner)
	assert(scenario)
	_runner = runner
	_scenario = scenario

	for id in _scenario.get_cue_list():
		var cue := _scenario.get_cue(id)
		if not cue._is_stateless():
			cue = cue.duplicate()
		if cue is YSNCueBegin:
			_begins[&'main'] = id # TODO: begin name


func _begin(name := &'main') -> void:
	var cue: YSNCueBegin = _cues.get(_begins.get(name, 0))
	if not cue:
		return
	# TODO
