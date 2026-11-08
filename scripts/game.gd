class_name Game
extends Node3D

@onready var debug_service := %DebugService as DebugService
@onready var camera_service := %CameraService as CameraService
@onready var level_service := %LevelService as LevelService

func _ready() -> void:
	Services.debug = debug_service
	Services.camera = camera_service
	Services.level = level_service
	Services.on_init.emit()
