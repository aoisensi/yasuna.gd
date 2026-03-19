@abstract
class_name YSNCueAsync extends YSNCue

const OUTPUT_COMPLETED = &'completed'


func task() -> void:
	await task_async()
	emit(OUTPUT_COMPLETED)

@abstract
func task_async() -> void

func get_outputs() -> Array[StringName]:
	return [OUTPUT_STARTED, OUTPUT_COMPLETED]
