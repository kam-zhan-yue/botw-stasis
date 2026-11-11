@tool
class_name StasisChain
extends Node3D

@export var mesh_instances: Array[MeshInstance3D]

var shader_material: ShaderMaterial
var current_direction := Vector3.ZERO
var initial_alpha := 0

func init() -> void:
	if len(mesh_instances) == 0:
		return
	var material_instance := mesh_instances[0].get_surface_override_material(0).duplicate()
	for mesh_instance in mesh_instances:
		mesh_instance.set_surface_override_material(0, material_instance) 
	shader_material = material_instance as ShaderMaterial
	initial_alpha = shader_material.get_shader_parameter("alpha")

func update_direction(direction: Vector3) -> void:
	current_direction = direction.normalized()
	look_at(global_position + current_direction, Vector3.UP)

func update_alpha(alpha: float) -> void:
	shader_material.set_shader_parameter("alpha", alpha)
