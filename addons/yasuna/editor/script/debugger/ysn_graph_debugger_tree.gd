@tool
extends Tree

signal instance_activated(instance_id: int)

var _root: TreeItem
var _runners: Dictionary[int, TreeItem] = { }
var _instances: Dictionary[int, TreeItem] = { }


func _init() -> void:
	_root = create_item()
	hide_root = true

	item_activated.connect(_on_item_activated)


func add_runner(runner_id: int, path: NodePath) -> void:
	var item := create_item(_root)
	_runners[runner_id] = item
	item.set_text(0, path)


func remove_runner(runner_id: int) -> void:
	var item := _runners[runner_id]
	_root.remove_child(item)
	_runners.erase(runner_id)


func add_instance(instance_id: int, runner_id: int, scenario_path: String) -> void:
	var item := create_item(_runners[runner_id])
	_instances[instance_id] = item
	item.set_meta(&'instance_id', instance_id)
	item.set_text(0, scenario_path)


func remove_instance(instance_id: int) -> void:
	var item := _instances.get(instance_id)
	if not item:
		return
	item.get_parent().remove_child(item)
	_instances.erase(instance_id)


func _on_item_activated() -> void:
	var item := get_selected()
	var id := item.get_meta(&'instance_id', null)
	if id:
		instance_activated.emit(id)
