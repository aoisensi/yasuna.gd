extends YSNUnitTestSuite

const WAIT_MARGIN := 50


func test_wait_0_0() -> void:
	await _test_wait(0.0)

func test_wait_0_2() -> void:
	await _test_wait(0.2)

func test_wait_0_5() -> void:
	await _test_wait(0.5)
	
func test_wait_1_0() -> void:
	await _test_wait(1.0)

func test_wait_5_0() -> void:
	await _test_wait(5.0)

func test_fuzzer_wait_restore(fuzzer_wait := Fuzzers.rangei(1000, 4000), _fuzzer_iterations := 5) -> void:
	var scenario := load_scenario('scenario/wait_5.0.sc.tres')
	var instance_before := runner.act(scenario)
	var monitor_before := monitor_signals(instance_before)
	var wait_before := fuzzer_wait.next_value()
	var wait_after := 5000 - wait_before
	@warning_ignore('redundant_await')
	await assert_signal(monitor_before).wait_until(wait_before).is_not_emitted(monitor_before.aborted)
	var capture := runner.capture()
	runner.abort_all()
	assert_signal(monitor_before).is_emitted(monitor_before.aborted)
	var instance_after := runner.restore(capture)[0]
	var monitor_after := monitor_signals(instance_after)
	@warning_ignore('redundant_await')
	await assert_signal(monitor_after).wait_until(wait_after - WAIT_MARGIN).is_not_emitted(monitor_after.completed)
	@warning_ignore('redundant_await')
	await assert_signal(monitor_after).wait_until(WAIT_MARGIN * 2).is_emitted(monitor_after.completed)
	assert_bool(instance_after.is_closed).is_true()

func _test_wait(sec: float) -> void:
	var scenario := load_scenario('scenario/wait_%.1f.sc.tres' % sec)
	var instance := runner.act(scenario)
	var monitor := monitor_signals(instance)
	if sec > 0.0:
		@warning_ignore('redundant_await')
		await assert_signal(monitor).wait_until(int(sec * 1000) - WAIT_MARGIN).is_not_emitted(monitor.completed)
	@warning_ignore('redundant_await')
	await assert_signal(monitor).wait_until(WAIT_MARGIN * 2).is_emitted(monitor.completed)
	assert_bool(instance.is_closed).is_true()
