tool
extends AcceptDialog

var duration: float

onready var _duration_field := $Margins/Content/Duration

var _context: GDScriptFunctionState


func open(timer_duration: float, context: GDScriptFunctionState) -> void:
	if _context: # opened from another slot
		_context.resume(false)
	_context = context
	
	show()
	duration = timer_duration
	_duration_field.text = str(timer_duration)
	_duration_field.caret_position = len(_duration_field.text)
	_duration_field.grab_focus()


func close() -> void:
	if _context:
		_context.resume(false)
	_context = null
	hide()


func _unhandled_input(event) -> void:
	if not visible:
		return
	if event.is_action("ui_accept"):
		emit_signal("confirmed")
		hide()


func _on_Duration_text_changed(new_text: String) -> void:
	if new_text.ends_with('.'):
		return
	duration = max(0, float(new_text))
	var caret_position = _duration_field.caret_position
	if 0 == duration:
		_duration_field.text = ""
	else:
		_duration_field.text = str(duration)
		_duration_field.caret_position = caret_position


func _on_confirmed() -> void:
	duration = float(_duration_field.text)
	_context.resume(true)
