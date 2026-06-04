@tool
@abstract
class_name YSNElement
extends Resource

signal position_offset_changed

var scenario: YSNScenario:
	get:
		return _scenario
var id: int:
	get:
		return _id
var _scenario: YSNScenario:
	set(value):
		_scenario = value
	get:
		return _scenario
var _id: int:
	set(value):
		_id = value
	get:
		return _id
