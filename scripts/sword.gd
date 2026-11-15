class_name Sword
extends Node3D

@export var hit_magnitude := 10.0
@export var hit_particles_scene: PackedScene

@onready var hitbox := %Hitbox as Hitbox
@onready var shape := %ShapeCast3D as ShapeCast3D

var collision_ids: Array[int]
var is_active := false

func set_active(active: bool) -> void:
	if active and not is_active:
		collision_ids.clear()
	is_active = active
	hitbox.set_active(active)


func _physics_process(_delta: float) -> void:
	var collision_count = shape.get_collision_count()
	if collision_count == 0 or not is_active:
		return
	for i in range(collision_count):
		_process_collision(i)


func _process_collision(i: int) -> void:
	var collider = shape.get_collider(i)
	if collider is not Node3D:
		return
	var collider_node = collider as Node3D
	if collider_node.get_parent() is not Hurtbox:
		return
	var hurtbox = collider_node.get_parent() as Hurtbox
	var hurtbox_id = hurtbox.get_instance_id()
	if hurtbox_id in collision_ids:
		return

	collision_ids.append(hurtbox_id)
	var collision_point = shape.get_collision_point(i)
	# Services.debug.hit(collision_point)
	_play_particles(collision_point)

	var hit = Hit.new(hit_magnitude, collision_point)
	hurtbox.hit(hit)

func _play_particles(target: Vector3) -> void:
	var particles := hit_particles_scene.instantiate() as ParticlePlayer
	Services.level.add_child(particles)
	particles.global_position = target
	particles.play()
