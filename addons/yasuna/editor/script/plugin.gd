@tool
extends EditorPlugin

const _YSNDebuggerPlugin = preload('./debugger_plugin.gd')
const _YSNGraphDock = preload('./graph/ysn_graph_dock.gd')

var _debugger: _YSNDebuggerPlugin
var _graph_dock: _YSNGraphDock


func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	_graph_dock = _YSNGraphDock.new()
	_graph_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	_graph_dock.title = 'Yasuna'
	add_dock(_graph_dock)

	_debugger = _YSNDebuggerPlugin.new()
	add_debugger_plugin(_debugger)

func _exit_tree() -> void:
	if _graph_dock:
		remove_dock(_graph_dock)
		_graph_dock.queue_free()
		_graph_dock = null

	if _debugger:
		remove_debugger_plugin(_debugger)
		_debugger = null

func _apply_changes() -> void:
	_graph_dock.save()

func _handles(object: Object) -> bool:
	return object is YSNScenario

func _edit(object: Object) -> void:
	if not object:
		return

	_graph_dock.edit(object)

func _make_visible(visible: bool) -> void:
	if visible:
		_graph_dock.make_visible()
