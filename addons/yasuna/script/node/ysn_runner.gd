@tool
class_name YSNRunner
extends Node

var _instances: Array[YSNInstance]
var _auto_acts: Array[Dictionary]


func _ready() -> void:
	call_deferred(&'_do_auto_act')

#region Property Access
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	for i in range(_auto_acts.size()):
		i += 1
		properties.append(
			{
				name = 'auto_acts/%d/scenario' % i,
				type = TYPE_OBJECT,
				hint = PROPERTY_HINT_RESOURCE_TYPE,
				usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_NEVER_DUPLICATE,
				hint_string = 'YSNScenario',
			},
		)
		properties.append(
			{
				name = 'auto_acts/%d/begin_name' % i,
				type = TYPE_STRING_NAME,
				usage = PROPERTY_USAGE_DEFAULT,
			},
		)
	properties.append(
		{
			name = 'auto_acts/%d/scenario' % (_auto_acts.size() + 1),
			type = TYPE_OBJECT,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_NO_INSTANCE_STATE,
			hint_string = 'YSNScenario',
		},
	)
	return properties


func _get(property: StringName) -> Variant:
	var ps := String(property).split('/')
	if ps.size() != 3:
		return null
	match ps[0]:
		'auto_acts':
			var id := int(ps[1]) - 1
			match ps[2]:
				'scenario':
					if id < _auto_acts.size():
						return _auto_acts[id].scenario
				'begin_name':
					return _auto_acts[id].begin_name
	return null


func _set(property: StringName, value: Variant) -> bool:
	var ps := String(property).split('/')
	if ps.size() != 3:
		return false
	match ps[0]:
		'auto_acts':
			var id := int(ps[1]) - 1
			match ps[2]:
				'scenario':
					if value is YSNScenario:
						if id == _auto_acts.size():
							_auto_acts.append({ })
							notify_property_list_changed()
						_auto_acts[id].scenario = value
					elif id < _auto_acts.size():
						_auto_acts.remove_at(id)
						notify_property_list_changed()
					return true
				'begin_name':
					_auto_acts[id][&'begin_name'] = value if value else &'main'
	return false
#endregion

#region Public Methods
func act(scenario: YSNScenario, begin_name := &'main') -> void:
	var instance := YSNInstance.new(self, scenario)
	_instances.append(instance)
	instance._begin(begin_name)
#endregion

func _do_auto_act() -> void:
	for a in _auto_acts:
		act(a.scenario, a.begin_name)
