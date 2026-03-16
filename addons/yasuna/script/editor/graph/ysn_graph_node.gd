@tool
extends GraphNode

var _cue: YSNCue

var cue: YSNCue:
	get:
		return _cue


func _init(cue: YSNCue) -> void:
	_cue = cue
	_cue.changed.connect(_on_cue_changed)
	_on_cue_changed()

func _on_cue_changed() -> void:
	title = _cue.get_title()
