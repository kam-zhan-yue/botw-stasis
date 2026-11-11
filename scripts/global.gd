@tool
extends Node3D

func seconds(time: float) -> void:
    await get_tree().create_timer(time).timeout

func get_random_direction_sphere() -> Vector3:
    var v = Vector3(
        randfn(0.0, 1.0),
        randfn(0.0, 1.0),
        randfn(0.0, 1.0)
    )
    return v.normalized()
