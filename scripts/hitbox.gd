class_name Hitbox
extends Node3D

@export var area_3d: Area3D

func _ready() -> void:
	area_3d.area_entered.connect(_on_area_entered)
	area_3d.monitoring = false

func set_active(active: bool) -> void:
	area_3d.monitoring = active

func _on_area_entered(area: Area3D) -> void:
	var area_parent := area.get_parent()
	if not area_parent is Hurtbox:
		return
	var hurtbox = area_parent as Hurtbox
	print("Hit ", hurtbox.name)

