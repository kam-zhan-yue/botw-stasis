class_name Hit
extends RefCounted

var magnitude: float
var origin_point: Vector3

func _init(mag: float, origin: Vector3) -> void:
	magnitude = mag
	origin_point = origin
