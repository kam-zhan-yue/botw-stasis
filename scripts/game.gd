class_name Game
extends Node3D

@onready var debug_service := %DebugService as DebugService

func _ready() -> void:
	Services.debug = debug_service
