class_name VFSMDemoTrafficLightsController
extends Node2D


var current_state_name: String setget _set_current_state_name
var available_actions: Array setget _set_available_actions


func green() -> void:
	$TrafficLights/Green/Cover.visible = false
	$TrafficLights/Yellow/Cover.visible = true
	$TrafficLights/Red/Cover.visible = true


func yellow() -> void:
	$TrafficLights/Green/Cover.visible = true
	$TrafficLights/Yellow/Cover.visible = false
	$TrafficLights/Red/Cover.visible = true


func red() -> void:
	$TrafficLights/Green/Cover.visible = true
	$TrafficLights/Yellow/Cover.visible = true
	$TrafficLights/Red/Cover.visible = false


func _set_current_state_name(value) -> void:
	if has_node("StateContainer/State"):
		$StateContainer/State.text = value


func _set_available_actions(value) -> void:
	available_actions = value.duplicate()
	$Actions/Actions.text = ""
	if available_actions.empty():
		return
	
	for action in available_actions:
		$Actions/Actions.text = action + ", "
	$Actions/Actions.text = $Actions/Actions.text.substr(0, len($Actions/Actions.text) - 2)

