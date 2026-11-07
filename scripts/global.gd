extends Node3D

func seconds(time: float) -> void:
    await get_tree().create_timer(time).timeout
