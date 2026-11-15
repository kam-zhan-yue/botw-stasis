@tool
class_name ParticlePlayer
extends Node3D

@export_tool_button("Play", "Callable") var debug_play = _editor_play

@export var particles: Array[GPUParticles3D]
@export var lifetime := 5.0

func play() -> void:
	for particle in particles:
		particle.emitting = true
	await Global.seconds(lifetime)
	queue_free()

func _editor_play() -> void:
	for particle in particles:
		particle.restart()
