class_name StasisArrow
extends Node3D

@export var mesh_instance: CSGBox3D

var shader_material: ShaderMaterial
var current_direction := Vector3.ZERO

func init() -> void:
	mesh_instance.material = mesh_instance.material.duplicate()
	shader_material = mesh_instance.material as ShaderMaterial

func update_direction(direction: Vector3) -> void:
	current_direction = direction.normalized()
	look_at(global_position + current_direction, Vector3.UP)

func update_color(color: Color) -> void:
	shader_material.set_shader_parameter("arrow_color", color)
