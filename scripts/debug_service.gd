class_name DebugService
extends Node3D

@export var debug_hit_scene: PackedScene

const DESPAWN_INTERVAL = 2

func hit(pos: Vector3) -> void:
	var hit_node := debug_hit_scene.instantiate() as Node3D
	add_child(hit_node)
	hit_node.global_position = pos
	await Global.seconds(DESPAWN_INTERVAL)
	hit_node.queue_free()
