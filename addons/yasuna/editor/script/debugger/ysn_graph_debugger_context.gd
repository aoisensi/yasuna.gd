@tool
extends RefCounted

const _YSNGraphDebugger = preload('./ysn_graph_debugger.gd')

var debugger: _YSNGraphDebugger
var instance_id: int


func emit_flow_for_debug(cue_id: int, flow: StringName) -> void:
	debugger._emit_cue_flow(instance_id, cue_id, flow)
