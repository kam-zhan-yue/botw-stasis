@tool
class_name StasisEffect
extends Node3D

@export_tool_button("Play", "Callable") var debug_play  = _editor_play

@export var chain_scene: PackedScene
@export var num_chains := 5
@export var fade_duration := 1.2
@export var move_duration := 0.2
@export var initial_distance := 10.0
@export var starting_alpha := 0.8

var chains: Array[StasisChain]
var tween: Tween

func play(target: Vector3) -> void:
	await _play_effect(target)
	_cleanup()


func _editor_play() ->  void:
	_editor_cleanup()
	await _play_effect(Vector3.ZERO)
	_editor_cleanup()


func _play_effect(target: Vector3) -> void:
	for i in range(num_chains):
		var chain = _spawn_chain()
		var direction := Global.get_random_direction_sphere()
		chain.init()
		chain.global_position = target + direction.normalized() * initial_distance
		chain.update_direction(direction)
		chains.append(chain)

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(_update_chains.bind(), starting_alpha, 0.0, fade_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUART)
	for chain in chains:
		tween.tween_property(chain, "global_position", target, move_duration)\
		.from(chain.global_position)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)

	await tween.finished


func _spawn_chain() -> StasisChain:
	var chain = chain_scene.instantiate() as StasisChain
	add_child(chain)
	return chain


func _update_chains(alpha: float) -> void:
	for chain in chains:
		chain.update_alpha(alpha)


func _cleanup() -> void:
	queue_free()


func _editor_cleanup() -> void:
	for chain in chains:
		chain.queue_free()
	chains.clear()
	if tween:
		tween.kill()
