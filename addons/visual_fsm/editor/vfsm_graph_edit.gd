tool
extends GraphEdit

onready var _new_trigger_dialog := $"../DialogLayer/NewScriptTriggerDialog"
onready var _new_state_dialog := $"../DialogLayer/NewStateDialog"
onready var _timer_duration_dialog := $"../DialogLayer/TimerDurationDialog"
onready var _input_action_dialog := $"../DialogLayer/InputActionDialog"

var _vfsm_start_scene: PackedScene = preload("vfsm_start_graph_node.tscn")
var _vfsm_state_scene: PackedScene = preload("vfsm_state_graph_node.tscn")
var _vfsm: VFSM
var _triggers := {}
var _state_node_creating_trigger: VFSMStateNode


func _ready() -> void:
#	var hbox := get_zoom_hbox()
#	var trigger_dropdown := MenuButton.new()
#	trigger_dropdown.text = "ScriptTriggers"
#	trigger_dropdown.flat = false
#	hbox.add_child(trigger_dropdown)
#	hbox.move_child(trigger_dropdown, 0)

	add_valid_left_disconnect_type(0)

	_new_trigger_dialog.rect_position = get_viewport_rect().size / 2 - _new_trigger_dialog.rect_size / 2

	edit(VFSM.new())


func edit(fsm: VFSM) -> void:
	if _vfsm:
		_vfsm.disconnect("changed", self, "_on_vfsm_changed")
	_vfsm = fsm
	if _vfsm:
		_vfsm.connect("changed", self, "_on_vfsm_changed")
	_redraw_graph()


func _on_vfsm_changed():
	_redraw_graph()


func _find_state_node(state: VFSMState) -> VFSMStateNode:
	for child in get_children():
		if child is VFSMStateNode and child.state == state:
			return child
	return null


func _redraw_graph():
#	print_debug("Redrawing fsm graph.............")

	# clear dialogs
	_new_state_dialog.close()
	_timer_duration_dialog.close()
	_input_action_dialog.close()

	clear_connections()
	# clear graph elements
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()

	if not _vfsm:
		return

	# add state nodes
	for state in _vfsm.get_states():
		var node: VFSMStateNode = _vfsm_state_scene.instance()
		node.timer_duration_dialog = _timer_duration_dialog
		node.input_action_dialog = _input_action_dialog
		add_child(node)
		node.connect("state_removed", self, "_on_StateNode_state_removed")
		node.connect(
			"new_script_request", self, "_on_StateNode_new_script_request")
		node.fsm = _vfsm
		node.state = state
		node.offset = state.position
		# add trigger slots
		for trigger in _vfsm.get_triggers_in_state(state):
			node.add_trigger(trigger)

	# add connections
	for from_state in _vfsm.get_states():
		var from_node := _find_state_node(from_state)
		for trigger in _vfsm.get_triggers_in_state(from_state):
			var to_state := _vfsm.get_to_state(from_state, trigger)
			if to_state:
				var to_node := _find_state_node(to_state)
				var from_port = from_state.get_trigger_index(trigger)
				assert(-1 < from_port, 
					"VisualFSM: Missing trigger \"%s\" in state \"%s\"" 
					% [trigger.name, from_state.name])
				connect_node(from_node.name, from_port, to_node.name, 0)

	# add start node
	var start_node = _vfsm_start_scene.instance()
	start_node.name = "VFSMStartNode"
	start_node.offset = _vfsm.start_position
	add_child(start_node)

	# add start connection
	var start_state := _vfsm.get_start_state()
	if start_state:
		var start_state_node := _find_state_node(start_state)
		connect_node(start_node.name, 0, start_state_node.name, 0)


func _try_create_new_state(from: String, from_slot: int, position: Vector2) -> void:
	if not yield():
		return

	var state_name: String = _new_state_dialog.state_name
	var state_position := position - Vector2(0, 40)
	var from_node = get_node(from)
	assert(from_node, "Missing node in create new state")
	if from_node is VFSMStateNode:
		var from_state: VFSMState = from_node.state
		var from_trigger_id := from_state.get_trigger_id_from_index(from_slot)
		var from_trigger := _vfsm.get_trigger(from_trigger_id)
		_vfsm.create_state(state_name, state_position, from_state, from_trigger)
	else: # from start node
		_vfsm.create_state(state_name, state_position)


func _on_connection_to_empty(from: String, from_slot: int, release_position: Vector2):
	var mouse_pos := get_global_mouse_position()
	_new_state_dialog.rect_position = mouse_pos - _new_state_dialog.rect_size / 2
	_new_state_dialog.open(_try_create_new_state(from, from_slot, release_position))


func _on_connection_request(
		from: String, from_slot: int, to: String, to_slot: int
	) -> void:
	if from.empty() or to.empty():
		push_warning("VisualFSM States must have names.")
		return
	
	var from_node: GraphNode = get_node(from)
	assert(from_node, "Missing from node in connection request")
	var to_node: VFSMStateNode = get_node(to)
	assert(to_node, "Missing tonode in connection request")
	if from_node is VFSMStateNode:
		var trigger_id: int = from_node.state.get_trigger_id_from_index(from_slot)
		var trigger := _vfsm.get_trigger(trigger_id)
		_vfsm.add_transition(from_node.state, trigger, to_node.state)
	else: # start node connection
		_vfsm.set_start_state(to_node.state)


func _on_disconnection_request(from, from_slot, to, to_slot):
	# hacky way to prtrigger weird connection lines when button held
	while Input.is_mouse_button_pressed(BUTTON_LEFT):
		yield(get_tree(), "idle_frame")

	yield(get_tree(), "idle_frame")
	# may have been removed during redraw. If so do nothing
	if not has_node(from) or not has_node(to):
		return

	var from_node: GraphNode = get_node(from)
	var to_node: VFSMStateNode = get_node(to)
	if from_node is VFSMStateNode:
		var trigger_id: int = from_node.state.get_trigger_id_from_index(from_slot)
		var trigger := _vfsm.get_trigger(trigger_id)
		_vfsm.remove_transition(from_node.state, trigger)
	else: # start node connection
		# start_target may have been reconnected during yield
		if _vfsm.get_start_state().vfsm_id == to_node.state.vfsm_id:
			_vfsm.set_start_state(null)


func _on_StateNode_state_removed(state_node: VFSMStateNode) -> void:
	_vfsm.remove_state(state_node.state)
	_vfsm.remove_state(state_node.state)


func _on_StateNode_rename_request(
	state_node: VFSMStateNode, new_name: String) -> void:
	var old_name := state_node.state.name
	var request_denied = false
	if new_name.empty():
		push_warning("VisualFSM: States must have names.")
		request_denied = true
	if _vfsm.has_state(new_name):
		push_warning("VisualFSM: A state named \"%s\" already exists." % new_name)
		request_denied = true
	if "Start" == new_name:
		push_warning("VisualFSM: The name \"Start\" is reserved." % new_name)
		request_denied = true

	if request_denied:
		return

#	print_debug("Renaming from %s to %s" % [old_name, new_name])
	_vfsm.rename_state(old_name, new_name)


func _on_end_node_move():
	for child in get_children():
		if child is VFSMStateNode:
			var state := _vfsm.get_state(child.state.vfsm_id)
			state.position = child.offset
		elif child is GraphNode and child.name == "VFSMStartNode":
			_vfsm.start_position = child.offset


func _try_create_new_script_trigger(state: VFSMState) -> void:
	if not yield():
		return

	var trigger_name: String = _new_trigger_dialog.trigger_name
	_vfsm.create_script_trigger(state, trigger_name)


func _on_StateNode_new_script_request(node: VFSMStateNode) -> void:
	var mouse_pos := get_global_mouse_position()
	_new_trigger_dialog.rect_position = mouse_pos - _new_trigger_dialog.rect_size / 2
	_new_trigger_dialog.open(_try_create_new_script_trigger(node.state))


func _on_Dialog_new_trigger_created(trigger: VFSMTrigger) -> void:
	_vfsm.add_trigger(trigger)
	_vfsm.add_script_transition(_state_node_creating_trigger.state.name, trigger.name)
	_state_node_creating_trigger = null
	_new_trigger_dialog.hide()


func _on_Dialog_trigger_name_request(trigger_name: String) -> void:
	if not _vfsm.has_script_trigger(trigger_name):
		_new_trigger_dialog.trigger_name = trigger_name
	else:
		_new_trigger_dialog.trigger_name = ""
		_new_trigger_dialog.name_request_denied(trigger_name)

func _on_StateCreateDialog_state_name_request(name: String) -> void:
	if not _vfsm.has_state(name):
		_new_state_dialog.approve_name_request(name)
	else:
		_new_state_dialog.deny_name_request(name)
