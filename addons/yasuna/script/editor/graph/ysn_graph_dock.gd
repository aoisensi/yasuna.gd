@tool
extends EditorDock

const _YSNGraphEdit := preload('./ysn_graph_edit.gd')

var _graph_edit: _YSNGraphEdit


func edit(scenario: YSNScenario) -> void:
	if scenario:
		if _graph_edit:
			remove_child(_graph_edit)
			_graph_edit.queue_free()

		_graph_edit = _YSNGraphEdit.new(scenario)
		add_child(_graph_edit)
