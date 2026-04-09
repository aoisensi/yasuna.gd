@abstract
class_name YSNUnitTestSuite extends GdUnitTestSuite

var runner: YSNRunner


func before_test() -> void:
	runner = YSNRunner.new()
	add_child(runner)

func after_test() -> void:
	remove_child(runner)
	runner.free()
	runner = null

func act_scenario(path: String, begin_name := &'main') -> YSNInstance:
	if path.is_relative_path():
		path = (get_script() as Script).resource_path.get_base_dir().path_join(path)
	var scenario := load(path) as YSNScenario
	return runner.act(scenario, begin_name)
