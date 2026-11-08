class_name StasisTarget
extends Node3D

enum State { Idle, Active, Highlight, Stasis }

@export var mesh_instance: CSGSphere3D
@export var hurtbox: Hurtbox
@export var rigidbody: RigidBody3D
@export var max_visual_force := 5000.0

var shader_material: ShaderMaterial

var state := State.Idle

var stasis_vector := Vector3.ZERO

func _ready() -> void:
	mesh_instance.material = mesh_instance.material.duplicate()
	shader_material = mesh_instance.material as ShaderMaterial
	hurtbox.on_hit.connect(_on_hit)
	Services.on_init.connect(_register)

func _register() -> void:
	Services.level.add_target(self)

func set_active(value: bool) -> void:
	if state == State.Stasis: return
	if value:
		_set_state(State.Active)
	else:
		_set_state(State.Idle)

func set_highlighted(value: bool) -> void:
	if state == State.Stasis: return
	if value:
		_set_state(State.Highlight)
	else:
		_set_state(State.Active)


func stasis(time: float) -> void:
	_set_state(State.Stasis)

	stasis_vector = Vector3.ZERO
	shader_material.set_shader_parameter("stasis_weight", 0)

	print("Start Stasis!")

	await Global.seconds(time)

	print("End Stasis!")
	
	_set_state(State.Idle)

	_apply_stasis_vector()
	shader_material.set_shader_parameter("stasis_weight", 0)

func _set_state(new_state: State) -> void:
	state = new_state
	shader_material.set_shader_parameter("state", state)
	pass

func _on_hit(hit: Hit) -> void:
	if state != State.Stasis:
		return

	var direction := global_position - hit.origin_point
	stasis_vector += hit.magnitude * direction
	var stasis_weight = min(stasis_vector.length() / max_visual_force, 1.0)
	shader_material.set_shader_parameter("stasis_weight", stasis_weight)

func _apply_stasis_vector() -> void:
	rigidbody.apply_impulse(stasis_vector)
