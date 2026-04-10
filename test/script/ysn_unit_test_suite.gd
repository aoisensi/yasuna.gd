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

func load_scenario(path: String) -> YSNScenario:
	if path.is_relative_path():
		path = (get_script() as Script).resource_path.get_base_dir().path_join(path)
	return load(path) as YSNScenario
