# res://scripts/player_utils.gd
extends Node

var current_level := 1

func load_next_level():
	current_level += 1
	var scene_path = "res://scenes/level_%d.tscn" % current_level
	get_tree().change_scene_to_file(scene_path)

func reload_current_level():
	var scene_path = "res://scenes/level_%d.tscn" % current_level
	get_tree().change_scene_to_file(scene_path)

func damage_player(
	player_ref: CharacterBody2D,
	anim: AnimatedSprite2D,
	life_container: Node,
	checkpoint_position: Vector2
) -> void:
	if not player_ref or not anim or not life_container:
		return
	if player_ref.get("already_damaged"):
		return
	player_ref.set("already_damaged", true)
	Engine.time_scale = 0.1
	anim.speed_scale = 1.0 / Engine.time_scale
	anim.play("damagetaken")
	life_container.reduce_life()
	await anim.animation_finished
	Engine.time_scale = 1
	anim.speed_scale = 1
	if life_container.get_child_count() > 0:
		player_ref.set_deferred("position", checkpoint_position + Vector2(-10, -32))
		player_ref.velocity = Vector2.ZERO
		anim.play("idle")
		player_ref.move_and_slide()
	else:
		get_tree().change_scene_to_file("res://scenes/died.tscn")

	player_ref.set("already_damaged", false)
