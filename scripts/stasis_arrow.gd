class_name StasisArrow
extends Node3D

@export var mesh_instance: MeshInstance3D

var shader_material: ShaderMaterial
var current_direction := Vector3.ZERO

func init() -> void:
	var material_instance := mesh_instance.get_surface_override_material(0).duplicate()
	mesh_instance.set_surface_override_material(0, material_instance) 
	shader_material = material_instance as ShaderMaterial

func update_direction(direction: Vector3) -> void:
	current_direction = direction.normalized()
	look_at(global_position + current_direction, Vector3.UP)

func update_color(color: Color) -> void:
	shader_material.set_shader_parameter("base_color", color)
