class_name PlayerController
extends CharacterBody3D

enum State { Normal, Attacking, Aiming }
enum AttackIndex { One, Two, Three, End }

@onready var camera_controller := %CameraController as CameraController
@onready var stasis_controller := %StasisController as StasisController
@onready var animation_tree := %AnimationTree as AnimationTree
@onready var sword := %Sword as Sword

@export var move_speed := 10.0
@export var attack_cooldown_interval := 1.0
@export var attack_hitbox_enable_interval_max := 1.2
@export var attack_hitbox_enable_interval_min := 0.5
@export var attackable_interval := 0.5
@export var stasis_spring_length := 1.5

var input_move_vector: Vector2

var state := State.Normal
var attack_index := AttackIndex.One
var attack_cooldown_timer := 0.0

func _input(event: InputEvent) -> void:
	if state == State.Normal and event.is_action_pressed("aim"):
		_aim()
	elif state == State.Normal and event.is_action_pressed("attack"):
		_attack()
	elif state == State.Attacking and event.is_action_pressed("attack"):
		_attack()
	elif state == State.Aiming and event.is_action_pressed("attack"):
		_stasis()
	elif state == State.Aiming and event.is_action_pressed("aim"):
		_aim_end()

## Process
func _process(delta: float) -> void:
	_process_walk_animation()
	_process_attack(delta)


func _process_attack(delta: float) -> void:
	if attack_cooldown_timer >= 0.0:
		attack_cooldown_timer -= delta

	if (attack_cooldown_timer >= attack_hitbox_enable_interval_min 
		and attack_cooldown_timer <= attack_hitbox_enable_interval_max 
		and state == State.Attacking):
		sword.set_active(true)
	else:
		sword.set_active(false)
	
	if attack_cooldown_timer <= 0.0 and state == State.Attacking:
		_reset_attack()


## Physics Process
func _physics_process(delta: float) -> void:
	match state:
		State.Normal:
			_physics_move(delta)
		State.Aiming:
			_physics_move(delta)
		State.Attacking:
			pass


func _physics_move(delta: float) -> void:
	input_move_vector = Input.get_vector(
		"right",
		"left",
		"backward",
		"forward"
	)

	var move_vector := _get_move_vector()

	velocity = Vector3(
		move_vector.x,
		0.0,
		move_vector.z
	)

	_rotate_to(velocity, delta)
	move_and_slide()


## Private Functions
func _start_aiming() -> void:
	pass

func _end_aiming() -> void:
	pass


func _rotate_to(direction: Vector3, delta: float) -> void:
	if direction.is_zero_approx():
		return

	var target_rotation := atan2(direction.x, direction.z)
	rotation.y = lerp_angle(
		rotation.y,
		target_rotation,
		10.0 * delta
	)


func _get_move_vector() -> Vector3:
	var forward := camera_controller.pcam.global_basis.z
	var right := -camera_controller.pcam.global_basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	var move_direction := (
		forward * -input_move_vector.y
		+ right * input_move_vector.x
	)

	return move_direction.normalized() * move_speed


func _process_walk_animation() -> void:
	animation_tree.set(
		"parameters/run/blend_position",
		1 if input_move_vector.length_squared() > 0.0 else 0
	)

func _reset_attack() -> void:
	state = State.Normal
	attack_index = AttackIndex.One
	sword.set_active(false)

func _aim() -> void:
	state = State.Aiming
	stasis_controller.set_active(true)
	camera_controller.lerp_spring_length(stasis_spring_length)

func _aim_end() -> void:
	state = State.Normal
	stasis_controller.set_active(false)
	camera_controller.reset_spring_length()

func _stasis() -> void:
	stasis_controller.stasis()
	_aim_end()

func _attack() -> void:
	if attack_index == AttackIndex.End or attack_cooldown_timer > attackable_interval:
		return
	var index = attack_index
	animation_tree.set("parameters/attack_1/request", _get_attack_request(index == AttackIndex.One))
	animation_tree.set("parameters/attack_2/request", _get_attack_request(index == AttackIndex.Two))
	animation_tree.set("parameters/attack_3/request", _get_attack_request(index == AttackIndex.Three))
	match attack_index:
		AttackIndex.One:
			attack_index = AttackIndex.Two
		AttackIndex.Two:
			attack_index = AttackIndex.Three
		AttackIndex.Three:
			attack_index = AttackIndex.End
	attack_cooldown_timer = attack_cooldown_interval
	state = State.Attacking


func _get_attack_request(fire: bool) -> AnimationNodeOneShot.OneShotRequest:
	if fire:
		return AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	return AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
