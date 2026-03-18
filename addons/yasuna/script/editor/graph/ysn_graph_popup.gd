extends PopupMenu

const _YSNGraphEdit = preload('./ysn_graph_edit.gd')

var _graph_edit: _YSNGraphEdit
var _scripts: Dictionary[int, Script]

var spawn_position: Vector2


func _init(graph_edit: _YSNGraphEdit) -> void:
	_graph_edit = graph_edit

	ProjectSettings.settings_changed.connect(_on_project_settings_settings_changed)
	id_pressed.connect(_on_id_pressed)

func _ready() -> void:
	_on_project_settings_settings_changed()

func _on_id_pressed(id: int) -> void:
	var scenario := _graph_edit.scenario
	scenario.add_cue(_scripts[id].new(), spawn_position)

func _on_project_settings_settings_changed() -> void:
	clear(true)
	_scripts = {}
	var class_list := ProjectSettings.get_global_class_list()

	for id in range(class_list.size()):
		var clazz := class_list[id]
		var script: Script = load(clazz[&'path'])
		if script.is_abstract():
			continue
		if not script.is_tool():
			continue
		if not _is_cue_script(script):
			continue
		add_item(clazz[&'class'], id)
		_scripts[id] = script
		

func _is_cue_script(script: Script) -> bool:
	if script.is_abstract():
		return false
	if not script.is_tool():
		return false
	if not script.can_instantiate():
		return false
	return _is_cue_script_recursion(script)

func _is_cue_script_recursion(script: Script) -> bool:
	if not script:
		return false
	if script == YSNCue:
		return true
	return _is_cue_script_recursion(script.get_base_script())
