class_name InputService
extends Node3D

var _captured := false

func _ready() -> void:
	_captured = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_input"):
		_captured = !_captured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _captured else Input.MOUSE_MODE_VISIBLE
