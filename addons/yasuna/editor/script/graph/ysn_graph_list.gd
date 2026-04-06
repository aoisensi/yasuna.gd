@tool
extends Tree

var _items: Dictionary[YSNScenario, TreeItem] = {}
var _root: TreeItem

signal scenario_activated(scenario: YSNScenario)
signal scenario_closed(scenario: YSNScenario)

const _COLUMN_TITLE = 0
const _COLUMN_CLOSE = 1
const _BUTTON_ID_CLOSE = 4


func _init() -> void:
	_root = create_item()
	
	hide_root = true
	item_activated.connect(_on_item_activated)
	button_clicked.connect(_on_button_clicked)

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

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var scenario = item.get_meta(&'scenario')
	match id:
		_BUTTON_ID_CLOSE:
			_items.erase(scenario)
			item.get_parent().remove_child(item)
			scenario_closed.emit(scenario)

func _create_item(scenario: YSNScenario) -> TreeItem:
	var item := create_item(_root)
	_items[scenario] = item
	item.set_meta(&'scenario', scenario)
	scenario.changed.connect(_on_scenario_changed.bind(scenario))
	_on_scenario_changed(scenario)

	var gui := EditorInterface.get_base_control()
	var close_icon := gui.get_theme_icon('Close', 'EditorIcons')
	item.add_button(0, close_icon, _BUTTON_ID_CLOSE)

	return item

func _on_scenario_changed(scenario: YSNScenario) -> void:
	var item: TreeItem = _items.get(scenario)
	if not item:
		return

	var title := scenario.title
	if title.is_empty():
		title = scenario.resource_path.get_file()

	item.set_text(0, title)
