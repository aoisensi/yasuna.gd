@tool
extends EditorDock

const _YSNGraphList := preload('./ysn_graph_list.gd')
const _YSNGraphEdit := preload('./ysn_graph_edit.gd')

var _split: HSplitContainer

var _empty: Control
var _graph_list: _YSNGraphList
var _graph_edit: _YSNGraphEdit


func save() -> void:
	_graph_edit.save()

func _init() -> void:
	_empty = Control.new()
	_split = HSplitContainer.new()
	_graph_list = _YSNGraphList.new()
	_graph_list.custom_minimum_size = Vector2(240.0, 0.0)
	_split.add_child(_graph_list)
	_split.add_child(_empty)
	add_child(_split)
	_graph_list.scenario_activated.connect(_on_graph_list_scenario_activated)
	_graph_list.scenario_closed.connect(_on_graph_list_scenario_closed)

func edit(scenario: YSNScenario) -> void:
	_graph_list.add(scenario)

func _on_graph_list_scenario_activated(scenario: YSNScenario) -> void:
	if not scenario:
		return
	if _graph_edit:
		_split.remove_child(_graph_edit)
		_graph_edit.save()
		_graph_edit.queue_free()
		_graph_edit = null
	else:
		_split.remove_child(_empty)

	_graph_edit = _YSNGraphEdit.new(scenario)
	_split.add_child(_graph_edit)
	_split.move_child(_graph_edit, 1)

func _on_graph_list_scenario_closed(scenario: YSNScenario) -> void:
	if not scenario:
		return
	if _graph_edit:
		if _graph_edit.scenario == scenario:
			_graph_edit.save()
			_split.remove_child(_graph_edit)
			_graph_edit.queue_free()
			_graph_edit = null
			_split.add_child(_empty)

func _on_plugin_resource_saved(resource: Resource) -> void:
	if resource is YSNScenario:
		_graph_list._on_scenario_changed(resource)
