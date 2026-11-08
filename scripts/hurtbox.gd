class_name Hurtbox
extends Node3D

signal on_hit(Hit)

func hit(hit_obj: Hit) -> void:
	on_hit.emit(hit_obj)
