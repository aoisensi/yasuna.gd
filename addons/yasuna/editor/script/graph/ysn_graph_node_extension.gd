@tool
@abstract
extends RefCounted

const _YSNGraphEdit := preload('./ysn_graph_edit.gd')

var cue: YSNCue
var read_only: bool
var debugging: bool
var _graph_edit: _YSNGraphEdit


@abstract
func _apply(node: GraphNode) -> void
