class_name CameraController
extends Node3D

@onready var pcam := $PhantomCamera3D as PhantomCamera3D
@onready var mouse_sensitivity := 5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var pcam_rotation := pcam.get_third_person_rotation_degrees()
		pcam_rotation.y -= event.relative.x * mouse_sensitivity
		pcam_rotation.x -= event.relative.y * mouse_sensitivity

		# Clamp vertical rotation to prevent flipping upside down
		pcam_rotation.x = clamp(pcam_rotation.x, -89.0, 89.0)

		pcam.set_third_person_rotation_degrees(pcam_rotation)
