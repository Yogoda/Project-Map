class_name VFSMDemoSimpleAIJumper
extends KinematicBody2D

export(float) var speed = 10
export(float) var jump_speed = 50
export(float) var gravity = 9.8

onready var right_gap_detector: RayCast2D= $RightGapDetector
onready var left_gap_detector: RayCast2D= $LeftGapDetector
onready var left_bottom_raycast: RayCast2D = $LeftBottom
onready var right_bottom_raycast: RayCast2D = $RightBottom
onready var left_middle_raycast: RayCast2D = $LeftMiddle
onready var right_middle_raycast: RayCast2D = $RightMiddle

var _velocity: Vector2


func move_x(dir: float) -> void:
	_velocity.x = clamp(dir, -1, 1) * speed


func jump() -> void:
	if is_on_floor():
		_velocity += jump_speed * Vector2.UP


func is_gap_in_front() -> bool:
	if _velocity.x > 0:
		return not right_gap_detector.is_colliding()
	else:
		return not left_gap_detector.is_colliding()


func is_impassable_in_front() -> bool:
	if _velocity.x > 0:
		return right_bottom_raycast.is_colliding() and right_middle_raycast.is_colliding()
	else:
		return left_bottom_raycast.is_colliding() and left_middle_raycast.is_colliding()


func is_jumpable_in_front() -> bool:
	if _velocity.x > 0:
		return right_bottom_raycast.is_colliding() and not right_middle_raycast.is_colliding()
	else:
		return left_bottom_raycast.is_colliding() and not left_middle_raycast.is_colliding()


func _ready() -> void:
	_velocity = Vector2()


func _physics_process(delta) -> void:
	_velocity += gravity * delta * Vector2.DOWN
	_velocity = move_and_slide(_velocity, Vector2.UP)
