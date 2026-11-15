class_name CameraController
extends Node3D

enum Mode { ThirdPerson, Shoulder }

@export var mouse_sensitivity := 5
@export var tween_time := 0.2
@export var target_follow_offset := -1.0

var initial_spring_length := 0.0
var initial_follow_offset := Vector3.ZERO
var spring_tween: Tween
var pcam: PhantomCamera3D

func _ready() -> void:
	Services.on_init.connect(_inject)

func _inject() -> void:
	pcam = Services.camera.third_person_camera

func _input(event: InputEvent) -> void:
	if not pcam: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var pcam_rotation := pcam.get_third_person_rotation_degrees()
		pcam_rotation.y -= event.relative.x * mouse_sensitivity
		pcam_rotation.x -= event.relative.y * mouse_sensitivity

		# Clamp vertical rotation to prevent flipping upside down
		pcam_rotation.x = clamp(pcam_rotation.x, -89.0, 89.0)

		pcam.set_third_person_rotation_degrees(pcam_rotation)


func switch_mode(mode: Mode) -> void:
	if pcam:
		pcam.priority = 0
	if mode == Mode.ThirdPerson:
		pcam = Services.camera.third_person_camera
	else:
		pcam = Services.camera.shoulder_camera
	pcam.priority = 10
