extends YSNUnitTestSuite

func test_wait_0_0() -> void:
	await _test_wait(0.0)

func test_wait_0_2() -> void:
	await _test_wait(0.2)

func test_wait_0_5() -> void:
	await _test_wait(0.5)
	
func test_wait_1_0() -> void:
	await _test_wait(1.0)

func _test_wait(sec: float) -> void:
	var instance := act_scenario('wait_%.1f.sc.tres' % sec)
	var monitor := monitor_signals(instance)
	if sec > 0.0:
		@warning_ignore('redundant_await')
		await assert_signal(monitor).wait_until(int(sec * 1000) - 50).is_not_emitted(monitor.closed)
	@warning_ignore('redundant_await')
	await assert_signal(monitor).wait_until(100).is_emitted(monitor.closed)
	assert_bool(instance.is_closed).is_true()
