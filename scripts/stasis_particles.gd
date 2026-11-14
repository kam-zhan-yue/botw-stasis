@tool
class_name StasisParticles
extends Node3D

@export_tool_button("Play", "Callable") var debug_play = _editor_play

@export var stasis_inward_particles: GPUParticles3D
@export var stasis_outward_particles: GPUParticles3D
@export var stasis_hit_particles: GPUParticles3D

const GAP = 0.1

func play() -> void:
	_play()
	await stasis_outward_particles.finished
	queue_free()

func _editor_play() -> void:
	_play()

func _play() -> void:
	stasis_inward_particles.emitting = true
	stasis_outward_particles.emitting = true
	stasis_hit_particles.emitting = true
