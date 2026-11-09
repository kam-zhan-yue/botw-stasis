class_name StasisArrow
extends Node3D

var _current_direction := Vector3.ZERO

func update_direction(direction: Vector3) -> void:
    _current_direction = direction.normalized()
    look_at(global_position + _current_direction, Vector3.UP)
