tool
class_name VFSMStateNode
extends GraphNode

signal state_removed(state_node)
signal new_script_request(state_node)

const COLORS := [
	Color.coral,
	Color.lightgreen,
	Color.aquamarine,
	Color.beige,
	Color.orchid,
	Color.brown,
	Color.magenta,
	Color.gold,
	Color.pink,
	Color.limegreen
]

export(Texture) var timer_icon
export(Texture) var action_icon
export(Texture) var script_icon

onready var _state_label := $TitlePanel/HBox/Margins/Name
onready var _add_trigger_dropdown := $BottomPanel/AddTriggerDropdown

var timer_duration_dialog: AcceptDialog
var input_action_dialog: AcceptDialog
var state: VFSMState setget _set_state
var fsm: VFSM
var _trigger_slot_scene: PackedScene = preload("vfsm_trigger_graph_slot.tscn")


func _ready() -> void:
	set_slot(0, true, 0, COLORS[0], false, 0, Color.white)
	var add_trigger_menu: PopupMenu = _add_trigger_dropdown.get_popup()
	add_trigger_menu.connect(
		"index_pressed", self, "_on_AddTrigger_index_pressed")
	add_trigger_menu.connect("focus_exited", add_trigger_menu, "hide")


func add_trigger(trigger: VFSMTrigger) -> void:
	if get_child_count() == COLORS.size() - 2:
		push_warning("VisualFSM: Maximum number of triggers in state %s reached!" 
			% self.state.name)
		return

	var slot_idx = get_child_count() - 1
	var next_to_last = get_child(slot_idx - 1)
	var trigger_slot: VFSMTriggerGraphSlot = _trigger_slot_scene.instance()
	add_child_below_node(next_to_last, trigger_slot)
	trigger_slot.timer_duration_dialog = timer_duration_dialog
	trigger_slot.input_action_dialog = input_action_dialog
	trigger_slot.connect("close_request", self, "_on_TriggerSlot_close_request")
	trigger_slot.trigger = trigger
	set_slot(slot_idx, false, 0, Color.white, true, 0, COLORS[slot_idx])


func _set_state(value: VFSMState) -> void:
	offset = value.position
	_state_label.text = value.name
	state = value


func _has_timer_trigger(state: VFSMState) -> bool:
	for trigger in fsm.get_triggers_in_state(state):
		if trigger is VFSMTriggerTimer:
			return true
	return false


func _on_AddTriggerDropdown_about_to_show() -> void:
	var popup: PopupMenu = _add_trigger_dropdown.get_popup()
	if not popup.is_inside_tree():
		yield(popup, "tree_entered")
	popup.clear()
	# important: this steals focus from state name and triggers validation
	popup.grab_focus()
	var options := []
	# TODO: potential issue with ordering
	for script_trigger in fsm.get_script_triggers():
		if not self.state.has_trigger(script_trigger.vfsm_id):
			options.push_back(script_trigger)
	for trigger in options:
		popup.add_icon_item(script_icon, trigger.name)
	if 0 < popup.get_item_count():
		popup.add_separator()
	if not _has_timer_trigger(self.state):
		popup.add_icon_item(timer_icon, "New timer trigger")
	popup.add_icon_item(action_icon, "New input action trigger")
	popup.add_icon_item(script_icon, "New script trigger")


func _on_AddTrigger_index_pressed(index: int) -> void:
	var popup: PopupMenu = _add_trigger_dropdown.get_popup()
	var num_items = popup.get_item_count()
	if num_items - 3 == index: # new timer
		fsm.create_timer_trigger(self.state)
	elif num_items - 2 == index: # new input action
		fsm.create_action_trigger(self.state)
	elif num_items - 1 == index: # new script
		emit_signal("new_script_request", self)
	else: # reuse existing script trigger
		var options := []
		for script_trigger in fsm.get_script_triggers():
			if not self.state.has_trigger(script_trigger.vfsm_id):
				options.push_back(script_trigger)
		var selected_trigger = options[index]
		self.state.add_trigger(selected_trigger)


func _on_StateGraphNode_close_request() -> void:
	emit_signal("state_removed", self)
	queue_free()


func _on_StateGraphNode_resize_request(new_minsize) -> void:
	rect_size = new_minsize


func _on_TriggerSlot_close_request(trigger_slot: VFSMTriggerGraphSlot) -> void:
	# TODO: Confirm
	fsm.remove_trigger_from_state(self.state, trigger_slot.trigger)


func _on_Script_pressed() -> void:
	$"/root/VFSMSingleton".emit_signal(
		"edit_custom_script", self.state.custom_script
	)
