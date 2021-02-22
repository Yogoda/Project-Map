tool
extends ConfirmationDialog

signal state_name_request(name)

onready var _state_name_field := $Margins/Content/StateName
onready var _name_status := $Margins/Content/Prompt/Margin/Name

var state_name: String setget _set_state_name
var _context: GDScriptFunctionState = null


func _ready() -> void:
	get_cancel().connect("pressed", self, "_on_canceled")


func open(context: GDScriptFunctionState) -> void:
	if _context:
		_context.resume(false)
	_context = context

	show()
	self.state_name = ""
	_state_name_field.grab_focus()


func close() -> void:
	if _context:
		_context.resume(false)
	_context = null
	hide()


func deny_name_request(name: String) -> void:
	_name_status.text = "A state with this name already exists." 
	_name_status.add_color_override("font_color", Color.red)


func approve_name_request(name: String) -> void:
	self.state_name = name


func _unhandled_input(event) -> void:
	if not _context:
		return

	if event is InputEventKey and event.scancode == KEY_ENTER and not get_ok().disabled:
		emit_signal("confirmed")
		hide()


func _set_state_name(value: String) -> void:
	state_name = value
	var caret_position = _state_name_field.caret_position
	_state_name_field.text = value
	_state_name_field.caret_position = caret_position
	_validate()


func _validate() -> void:
	var ok_button = get_ok()
	var invalid_state_name: bool = self.state_name.empty()
	if invalid_state_name:
		_name_status.text = "State must have a name."
		_name_status.add_color_override("font_color", Color.red)
	else:
		_name_status.text = "State name is available."
		_name_status.add_color_override("font_color", Color.green)

	ok_button.disabled = invalid_state_name


func _on_confirmed() -> void:
	_context.resume(true)
	_context = null


func _on_canceled() -> void:
	_context.resume(false)
	_context = null


func _on_StateName_text_changed(text: String) -> void:
	emit_signal("state_name_request", text)
