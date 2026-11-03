class_name PlayerController
extends CharacterBody3D

@export var move_speed := 100.0

var input_vector: Vector2

func _input(_event: InputEvent) -> void:
	input_vector = Input.get_vector("forward", "backward", "left", "right")



func _physics_process(delta: float) -> void:
	var move_vector = _get_move_vector() * delta
	velocity = Vector3(move_vector.x, 0, move_vector.y)
	_rotate_to(velocity, delta)
	move_and_slide()

func _rotate_to(direction: Vector3, delta: float) -> void:
	if direction == Vector3.ZERO:
		return
	var target_rotation := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta)


func _get_move_vector() -> Vector2:
	var move_vector := move_speed * input_vector.normalized()
	return Vector2(move_vector.y, move_vector.x)
