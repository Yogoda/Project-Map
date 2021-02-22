tool
extends EditorPlugin

const CONTROL_LABEL := "Finite State Machine"
const FSM_TYPE_NAME := "VisualFSM"

var _fsm_editor: Control
var _tool_button: ToolButton
var _fsm_script := preload("visual_fsm.gd")
var _fsm_singleton: VFSMSingleton = preload("vfsm_singleton.gd").new()
var _current_fsm_node


func _enter_tree() -> void:
	add_custom_type(FSM_TYPE_NAME, "Node", _fsm_script, preload("resources/icons/visual_fsm.png"))

	yield(get_tree(), "idle_frame")
	_fsm_singleton.name = "VFSMSingleton"
	_fsm_singleton.connect("edit_custom_script", self, "_on_edit_custom_script")
	get_tree().root.add_child(_fsm_singleton)

	_fsm_editor = preload("editor/vfsm_editor.tscn").instance()
	_tool_button = add_control_to_bottom_panel(_fsm_editor, CONTROL_LABEL)
	_tool_button.hide()
	var selected_nodes := get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() > 0:
		make_visible(handles(selected_nodes[0]))


func _exit_tree() -> void:
	remove_custom_type(FSM_TYPE_NAME)
	_fsm_singleton.disconnect("edit_custom_script", self, "_on_edit_custom_script")
	remove_control_from_bottom_panel(_fsm_editor)

	get_tree().root.call_deferred("remove_child", _fsm_singleton)
	# using queue_free causes memory leaks. Bug?
	_fsm_editor.free()


func make_visible(visible) -> void:
	if visible:
		_tool_button.show()
		make_bottom_panel_item_visible(_fsm_editor)
		_fsm_editor.set_process(true)
	else:
		if _fsm_editor.visible:
			hide_bottom_panel()
		_tool_button.hide()
		_fsm_editor.set_process(false)


func handles(object) -> bool:
	return object is _fsm_script


func edit(object) -> void:
	_fsm_editor.edit(object)
	_current_fsm_node = object


func _on_edit_custom_script(custom_script: GDScript) -> void:
	assert(_current_fsm_node, "VisualFSM: Current VisualFSM node is null.")
	get_editor_interface().edit_resource(custom_script)
	# inspect current fsm node, otherwise we lose the fsm panel
	get_editor_interface().inspect_object(_current_fsm_node)
