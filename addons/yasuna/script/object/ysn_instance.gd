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
			cue._instance = self
		_cues[id] = cue


func _emit_flow(id: int, output: StringName) -> void:
	var c: String = _scenario._connections.get('%d/%s' % [id, output], '')
	if not c:
		return
	var cs := c.split('/')
	var next_id := int(cs[0])
	var cue := _cues[next_id]
	var context := YSNContext.new(self, next_id, StringName(cs[1]))
	cue._perform(context)


func _begin(name := &'main') -> void:
	for id in _cues:
		var cue := _cues[id] as YSNCueBegin
		if not cue:
			continue
		if cue.begin_name == name:
			_emit_flow(id, YSNCue.OUTPUT_THEN)
