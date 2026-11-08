class_name StasisTarget
extends Node3D

enum State { Idle, Target, Stasis }

@export var mesh_instance: CSGSphere3D
@export var hurtbox: Hurtbox
@export var rigidbody: RigidBody3D

var shader_material: ShaderMaterial

var state := State.Idle

var stasis_vector := Vector3.ZERO

func _ready() -> void:
	mesh_instance.material = mesh_instance.material.duplicate()
	shader_material = mesh_instance.material as ShaderMaterial
	hurtbox.on_hit.connect(_on_hit)

func set_highlighted(value: bool) -> void:
	if state == State.Stasis:
		return
	shader_material.set_shader_parameter("highlight", value)


func stasis(time: float) -> void:
	state = State.Stasis
	shader_material.set_shader_parameter("highlight", false)
	shader_material.set_shader_parameter("stasis", true)

	stasis_vector = Vector3.ZERO

	print("Start Stasis!")

	await Global.seconds(time)

	print("End Stasis!")

	state = State.Idle
	shader_material.set_shader_parameter("highlight", false)
	shader_material.set_shader_parameter("stasis", false)

	_apply_stasis_vector()

func _on_hit(hit: Hit) -> void:
	if state != State.Stasis:
		return

	var direction := global_position - hit.origin_point
	stasis_vector += hit.magnitude * direction

func _apply_stasis_vector() -> void:
	rigidbody.apply_impulse(stasis_vector)
	pass
