@tool
class_name StasisParticles
extends Node3D

@export var stasis_inward_particles: GPUParticles3D
@export var stasis_outward_particles: GPUParticles3D

const GAP = 0.1

func play() -> void:
	stasis_inward_particles.emitting = true
	await Global.seconds(GAP)
	stasis_outward_particles.emitting = true
	await stasis_outward_particles.finished
	queue_free()
