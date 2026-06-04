@tool
extends EditorPlugin

const DOMAIN = &'info.aoisensi.yasuna'
const TRANSLATION_PATH = 'res://addons/yasuna/editor/translation'
const _Dock = preload('./dock.gd')

var _dock: _Dock


func _enter_tree() -> void:
	set_translation_domain(DOMAIN)

	if not _dock:
		_dock = _Dock.new()
	add_dock(_dock)

	var domain := TranslationServer.get_or_add_domain(DOMAIN)
	var dir := DirAccess.open(TRANSLATION_PATH)
	if dir:
		for file in dir.get_files():
			if file.get_extension() != 'po':
				continue
			var translation := load(TRANSLATION_PATH.path_join(file)) as Translation
			if not translation:
				continue
			domain.add_translation(translation)


func _exit_tree() -> void:
	remove_dock(_dock)
	_dock.queue_free()
	_dock = null

	TranslationServer.remove_domain(DOMAIN)


func _handles(object: Object) -> bool:
	return object is YSNScenario


func _edit(object: Object) -> void:
	if object is YSNScenario:
		_dock._edit(object)


func _make_visible(visible: bool) -> void:
	if visible:
		_dock.make_visible()
