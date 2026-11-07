class_name CameraController
extends Node3D

@onready var pcam := $PhantomCamera3D as PhantomCamera3D
@onready var mouse_sensitivity := 5
@export var tween_time := 0.2

var initial_spring_length := 0.0
var spring_tween: Tween

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	initial_spring_length = pcam.spring_length

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var pcam_rotation := pcam.get_third_person_rotation_degrees()
		pcam_rotation.y -= event.relative.x * mouse_sensitivity
		pcam_rotation.x -= event.relative.y * mouse_sensitivity

		# Clamp vertical rotation to prevent flipping upside down
		pcam_rotation.x = clamp(pcam_rotation.x, -89.0, 89.0)

		pcam.set_third_person_rotation_degrees(pcam_rotation)


func lerp_spring_length(length: float) -> void:
	if spring_tween:
		spring_tween.kill()
	spring_tween = create_tween()
	spring_tween.tween_property(pcam, "spring_length", length, tween_time)\
			.from_current()\
			.set_ease(Tween.EASE_OUT)
	spring_tween.play()

func reset_spring_length() -> void:
	if spring_tween:
		spring_tween.kill()
	spring_tween = create_tween()
	spring_tween.tween_property(pcam, "spring_length", initial_spring_length, tween_time)\
			.from_current()\
			.set_ease(Tween.EASE_OUT)
	spring_tween.play()
