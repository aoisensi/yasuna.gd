@tool
extends EditorDock

const _Plugin = preload('./plugin.gd')
const _GraphEdit = preload('./graph/graph_edit.gd')
const _GraphPopupAdd = preload('./graph/graph_popup_add.gd')

var _graph_edit: _GraphEdit
var _graph_popup_add := _GraphPopupAdd.new()


func _init() -> void:
	set_translation_domain(_Plugin.DOMAIN)
	title = tr('Yasuna')
	default_slot = EditorDock.DOCK_SLOT_BOTTOM

	add_child(_graph_popup_add)


func _edit(scenario: YSNScenario) -> void:
	if _graph_edit:
		remove_child(_graph_edit)
		_graph_edit.queue_free()
		_graph_edit = null

	_graph_edit = _GraphEdit.new(scenario)
	add_child(_graph_edit)
	_graph_edit.popup_request.connect(_on_graph_edit_popup_request)


func _on_graph_edit_popup_request(at_position: Vector2) -> void:
	_graph_popup_add.scenario = _graph_edit._scenario
	_graph_popup_add.at_position = at_position
	_graph_popup_add.position = _graph_edit.global_position + at_position
	_graph_popup_add.popup()
