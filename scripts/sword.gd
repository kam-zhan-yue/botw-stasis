class_name Sword
extends Node3D

@onready var hitbox := %Hitbox as Hitbox

var is_active := false

func set_active(active: bool) -> void:
	is_active = active
	hitbox.set_active(active)
