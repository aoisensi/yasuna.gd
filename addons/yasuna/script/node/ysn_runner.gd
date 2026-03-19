class_name YSNRunner extends Node

@export var auto_begin: Array[YSNScenario]

var _running_cues: Dictionary[YSNCue, bool] = {} # actually this is a set

signal _cue_act(cue: YSNCue)


func _init() -> void:
	_cue_act.connect(_on_cue_act)

func _ready() -> void:
	if auto_begin:
		for scenario in auto_begin:
			act(scenario)

func act(scenario: YSNScenario) -> void:
	_cue_act.emit(scenario._cue_begin)

func _on_cue_act(cue: YSNCue) -> void:
	cue = cue._duplicate_cue(self)
	if cue is YSNCueAsync:
		_running_cues[cue] = false
	cue._action()

func _cue_finished(cue: YSNCue) -> void:
	if cue.is_async_task():
		_running_cues.erase(cue)
	cue.free()
