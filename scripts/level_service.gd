class_name LevelService
extends Node3D

var stasis_targets: Array[StasisTarget] = []

func add_target(target: StasisTarget) -> void:
	stasis_targets.append(target)
