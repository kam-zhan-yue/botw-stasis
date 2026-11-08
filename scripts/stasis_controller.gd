class_name StasisController
extends Node3D

@export var stasis_time := 5.0

var is_active := false
var targeting: StasisTarget

func set_active(active: bool) -> void:
	is_active = active
	if not active and targeting:
		targeting.set_highlighted(false)
	targeting = null

func stasis() -> void:
	if not targeting:
		return
	targeting.stasis(stasis_time)

func _physics_process(_delta: float) -> void:
	if not is_active: return
	var collider = Services.camera.raycast.get_collider()
	if collider is not StasisTarget: 
		if targeting:
			targeting.set_highlighted(false)
		targeting = null
		return

	var stasis_target = collider as StasisTarget
	if targeting and targeting != stasis_target:
		targeting.set_highlighted(false)
	stasis_target.set_highlighted(true)
	targeting = stasis_target
