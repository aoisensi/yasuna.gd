@tool
extends '../ysn_graph_node_extension.gd'

var _property: StringName


func _init(property: StringName) -> void:
	_property = property


func _apply(node: GraphNode) -> void:
	var titlebar := node.get_titlebar_hbox()
	titlebar.add_child(_create_button(preload('../../../resource/icon/caret-up.svg'), -1))
	titlebar.add_child(_create_button(preload('../../../resource/icon/caret-down.svg'), +1))


func _create_button(texture: Texture2D, n: int) -> TextureButton:
	var button := TextureButton.new()
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.disabled = read_only
	button.texture_normal = texture
	button.pressed.connect(_on_button_pressed.bind(n))
	return button


func _on_button_pressed(n: int) -> void:
	var current := cue.get(_property)
	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action('Change Cue Counter')
	undo_redo.add_do_property(cue, _property, current + n)
	undo_redo.add_undo_property(cue, _property, current)
	undo_redo.commit_action()
