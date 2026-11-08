class_name Game
extends Node3D

@onready var debug_service := %DebugService as DebugService
@onready var camera_service := %CameraService as CameraService

func _ready() -> void:
	Services.debug = debug_service
	Services.camera = camera_service
