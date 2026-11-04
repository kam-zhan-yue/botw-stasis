class_name PlayerController
extends CharacterBody3D

enum State { Walking, Attacking }
enum AttackIndex { One, Two, Three, End }

@export var move_speed := 10.0
@export var attack_cooldown_interval := 1.3
@export var attackable_interval := 0.8
@export var pcam: PhantomCamera3D

@onready var animation_tree := %AnimationTree as AnimationTree

var input_move_vector: Vector2
var input_attack_requested := false

var state := State.Walking
var attack_index := AttackIndex.One
var attack_cooldown_timer := 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		print("attack")
		input_attack_requested = true


## Process
func _process(delta: float) -> void:
	_process_walk_animation()
	_process_attack(delta)


func _process_attack(delta: float) -> void:
	if attack_cooldown_timer >= 0.0:
		attack_cooldown_timer -= delta
	
	if attack_cooldown_timer <= 0.0:
		state = State.Walking
		attack_index = AttackIndex.One

	if !input_attack_requested:
		return

	input_attack_requested = false

	if attack_index == AttackIndex.End or attack_cooldown_timer > attackable_interval:
		return

	_enter_attack(attack_index)


func _enter_attack(index: AttackIndex) -> void:
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

## Physics Process
func _physics_process(delta: float) -> void:
	match state:
		State.Walking:
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
	var forward := pcam.global_basis.z
	var right := -pcam.global_basis.x

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
