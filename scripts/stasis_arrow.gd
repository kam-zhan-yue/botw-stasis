@tool
class_name StasisArrow
extends Node3D

@export_tool_button("Play", "Callable") var debug_play = _editor_play
@export var _editor_progress := 0.0

@export var mesh_instance: MeshInstance3D
@export var scale_animation_time := 0.5
@export var max_scale: float
@export var scale_curve: Curve

var shader_material: ShaderMaterial
var current_direction := Vector3.ZERO
var tween: Tween

func init() -> void:
	var material_instance := mesh_instance.get_surface_override_material(0).duplicate()
	mesh_instance.set_surface_override_material(0, material_instance) 
	shader_material = material_instance as ShaderMaterial
	scale = Vector3.ZERO

func update_direction(direction: Vector3) -> void:
	current_direction = direction.normalized()
	look_at(global_position + current_direction, Vector3.UP)

func update_color(color: Color) -> void:
	shader_material.set_shader_parameter("base_color", color)

func update_scale(progress: float) -> void:
	var multiplier := clampf(scale_curve.sample(progress), 0.0, 1.0)
	var target_scale := clampf(max_scale * multiplier, 0.01, max_scale)

	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * target_scale, scale_animation_time)\
			.from_current()\
			.set_trans(Tween.TRANS_BOUNCE)\
			.set_ease(Tween.EASE_OUT)
	tween.play()

func _editor_play() -> void:
	update_scale(_editor_progress)
