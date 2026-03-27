@tool
extends Tree

var _items: Dictionary[YSNScenario, TreeItem] = {}
var _root: TreeItem

signal scenario_activated(scenario: YSNScenario)


func _init() -> void:
	_root = create_item()
	hide_root = true
	item_activated.connect(_on_item_activated)

func add(scenario: YSNScenario) -> void:
	var item := _items.get(scenario)
	if not item:
		item = _create_item(scenario)

	set_selected(item, 0)
	item_activated.emit()

func _on_item_activated() -> void:
	var scenario := get_selected().get_meta(&'scenario')
	if scenario:
		scenario_activated.emit(scenario)

func _create_item(scenario: YSNScenario) -> TreeItem:
	var item := create_item(_root)
	_items[scenario] = item
	item.set_meta(&'scenario', scenario)
	scenario.changed.connect(_on_scenario_changed.bind(scenario))
	_on_scenario_changed(scenario)
	return item

func _on_scenario_changed(scenario: YSNScenario) -> void:
	var item: TreeItem = _items.get(scenario)
	if not item:
		return
	var text := ''
	if scenario.resource_path:
		text += scenario.resource_path
	else:
		text += scenario.resource_name

	item.set_text(0, text)
