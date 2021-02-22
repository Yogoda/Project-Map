tool
class_name VFSMTriggerTimer
extends VFSMTrigger

export(float) var duration

var _timer: float


func enter() -> void:
	_timer = 0


func is_over(delta: float) -> bool:
	_timer += delta
	if duration < _timer:
		return true
	return false
