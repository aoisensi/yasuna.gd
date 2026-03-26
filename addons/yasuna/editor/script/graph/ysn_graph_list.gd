@tool
extends Tree

var _scenarios: Dictionary[TreeItem, YSNScenario] = {}
var _root: TreeItem

signal scenario_activated(scenario: YSNScenario)


func _init() -> void:
	_root = create_item()
	hide_root = true
	item_activated.connect(_on_item_activated)

func add(scenario: YSNScenario) -> void:
	var item := _scenarios.find_key(scenario)
	if not item:
		item = _create_item(scenario)

	set_selected(item, 0)
	item_activated.emit()

func _on_item_activated() -> void:
	scenario_activated.emit(_scenarios[get_selected()])

func _create_item(scenario: YSNScenario) -> TreeItem:
	var item := create_item(_root)
	_scenarios[item] = scenario
	_update_item(item)
	return item

func _update_item(item: TreeItem) -> void:
	var scenario := _scenarios[item]

	if scenario.resource_path:
		item.set_text(0, scenario.resource_path)
	else:
		item.set_text(0, scenario.resource_name)
