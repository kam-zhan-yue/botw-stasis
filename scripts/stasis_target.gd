class_name StasisTarget
extends Node3D

enum State { Idle, Active, Highlight, Stasis }

@export var mesh_instance: CSGSphere3D
@export var hurtbox: Hurtbox
@export var rigidbody: RigidBody3D
@export var max_visual_force := 5000.0
@export var stasis_arrow_scene: PackedScene

var shader_material: ShaderMaterial

var state := State.Idle

var stasis_launch_magnitude := 0.0
var stasis_launch_direction := Vector3.ZERO
var stasis_arrow: StasisArrow

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

	stasis_launch_magnitude = 0.0
	stasis_launch_direction = Vector3.ZERO
	shader_material.set_shader_parameter("stasis_weight", 0)
	rigidbody.freeze = true
	rigidbody.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

	await Global.seconds(time)
	
	_set_state(State.Idle)

	rigidbody.freeze = false
	shader_material.set_shader_parameter("stasis_weight", 0)
	_clear_stasis_arrow()
	_apply_stasis_vector()

func _set_state(new_state: State) -> void:
	state = new_state
	shader_material.set_shader_parameter("state", state)

func _on_hit(hit: Hit) -> void:
	if state != State.Stasis:
		return

	var direction := global_position - hit.origin_point
	stasis_launch_magnitude += hit.magnitude;
	stasis_launch_direction = direction.normalized()
	var stasis_weight = min(stasis_launch_magnitude / max_visual_force, 1.0)
	shader_material.set_shader_parameter("stasis_weight", stasis_weight)
	var stasis_start_color = shader_material.get_shader_parameter("stasis_start_color")
	var stasis_end_color = shader_material.get_shader_parameter("stasis_end_color")
	var stasis_color := lerp(stasis_start_color, stasis_end_color, stasis_weight) as Color
	_update_stasis_arrow(stasis_color)

func _update_stasis_arrow(color: Color) -> void:
	if stasis_arrow == null:
		stasis_arrow = stasis_arrow_scene.instantiate() as StasisArrow
		add_child(stasis_arrow)
		stasis_arrow.init()
	stasis_arrow.update_direction(stasis_launch_direction.normalized())
	stasis_arrow.update_color(color)

func _clear_stasis_arrow() -> void:
	if stasis_arrow != null:
		stasis_arrow.queue_free()
		stasis_arrow = null

func _apply_stasis_vector() -> void:
	var launch_vector := stasis_launch_direction.normalized() * stasis_launch_magnitude;
	rigidbody.apply_impulse(launch_vector)
