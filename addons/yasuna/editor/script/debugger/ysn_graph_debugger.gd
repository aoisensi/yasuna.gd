@tool
extends HSplitContainer

const _YSNGraphDebuggerTree = preload('./ysn_graph_debugger_tree.gd')
const _YSNGraphEdit = preload('../graph/ysn_graph_edit.gd')


var _tree: _YSNGraphDebuggerTree
var _edit: _YSNGraphEdit

var _session: EditorDebuggerSession

var _instances: Dictionary[int, String] = {}

var _active_instance_id: int

signal flow_emitted(cue_id: int, emit_flow: StringName) # TODO: maybe bad


func _init(session: EditorDebuggerSession) -> void:
	assert(session)
	_session = session

	session.stopped.connect(_on_session_stopped)

	_create_tree()

func _on_session_stopped() -> void:
	_create_tree()

func _on_tree_instance_activated(instance_id: int) -> void:
	_active_instance_id = instance_id
	var scenario_path := _instances[instance_id]
	var scenario := load(scenario_path) as YSNScenario
	_create_edit(scenario)

func _create_tree() -> void:
	if _tree:
		_tree.queue_free()
	_tree = _YSNGraphDebuggerTree.new()
	_tree.custom_minimum_size = Vector2(240.0, 0.0)
	_tree.instance_activated.connect(_on_tree_instance_activated)
	add_child(_tree)
	move_child(_tree, 0)

func _create_edit(scenario: YSNScenario) -> void:
	if _edit:
		remove_child(_edit)
		_edit.queue_free()
	_edit = _YSNGraphEdit.new(scenario, self)
	add_child(_edit)
	move_child(_edit, 1)

func _runner_entered(runner_id: int, path: NodePath) -> void:
	_tree.add_runner(runner_id, path)

func _runner_exited(runner_id: int) -> void:
	_tree.remove_runner(runner_id)

func _instance_started(instance_id: int, runner_id: int, scenario_path: String) -> void:
	_instances[instance_id] = scenario_path
	_tree.add_instance(instance_id, runner_id, scenario_path)

func _instance_closed(instance_id: int) -> void:
	_instances.erase(instance_id)
	_tree.remove_instance(instance_id)

func _cue_flow_emitted(instance_id: int, cue_id: int, emit_flow: StringName) -> void:
	if instance_id == _active_instance_id:
		flow_emitted.emit(cue_id, emit_flow)
