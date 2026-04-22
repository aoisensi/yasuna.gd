@tool
extends EditorDebuggerPlugin

const _YSNGraphDebugger = preload('./debugger/ysn_graph_debugger.gd')

var _debuggers: Dictionary[int, _YSNGraphDebugger] = { }


func _has_capture(capture: String) -> bool:
	return capture == 'yasuna'


func _capture(message: String, data: Array, session_id: int) -> bool:
	var debugger := _debuggers[session_id]
	match message:
		'yasuna:runner_entered':
			debugger._runner_entered(data[0], data[1])
		'yasuna:runner_exited':
			debugger._runner_exited(data[0])
		'yasuna:instance_started':
			debugger._instance_started(data[0], data[1], data[2])
		'yasuna:instance_closed':
			debugger._instance_closed(data[0])
		'yasuna:cue_flow_emitted':
			debugger._cue_flow_emitted(data[0], data[1], data[2])
		_:
			return false
	return true


func _setup_session(session_id: int) -> void:
	var session := get_session(session_id)
	var debugger := _YSNGraphDebugger.new(session)
	debugger.name = 'Yasuna'
	_debuggers[session_id] = debugger
	session.add_session_tab(debugger)
