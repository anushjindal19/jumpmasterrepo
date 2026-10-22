# res://scripts/player_utils.gd
extends Node

const LAST_LEVEL := 3
const SAVE_PATH := "user://save.cfg"

signal score_changed(score: int)

var current_level := 1
var level_time := 0.0  # Seconds spent in the current level, counted by level_1.gd
var score := 0  # Fruit points collected in the current level

# Results of the level that was just finished, shown on the next_level screen
var last_score := 0
var last_time := 0.0
var best_score := 0
var best_time := 0.0
var is_new_best_score := false
var is_new_best_time := false

func is_last_level() -> bool:
	return current_level >= LAST_LEVEL

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

# Called by level_1.gd when a level (re)starts
func start_level() -> void:
	level_time = 0.0
	score = 0
	score_changed.emit(score)

# Records the run and updates the saved best score and time for this level
func finish_level() -> void:
	last_score = score
	last_time = level_time
	var save := ConfigFile.new()
	save.load(SAVE_PATH)  # Fails on the first run, which just leaves it empty
	var section := "level_%d" % current_level
	var old_best_score: int = save.get_value(section, "best_score", -1)
	var old_best_time: float = save.get_value(section, "best_time", INF)
	is_new_best_score = score > old_best_score
	is_new_best_time = last_time < old_best_time
	best_score = score if is_new_best_score else old_best_score
	best_time = last_time if is_new_best_time else old_best_time
	save.set_value(section, "best_score", best_score)
	save.set_value(section, "best_time", best_time)
	save.save(SAVE_PATH)

# Jiggles the player's camera for a moment. Runs in real time so the damage slow-mo doesn't stretch it
func shake_camera(player_ref: Node, strength: float, duration := 0.3) -> void:
	var cam: Camera2D = player_ref.get_node_or_null("Camera2D")
	if not cam:
		return
	var tween := cam.create_tween().set_ignore_time_scale(true)
	var steps := 6
	for i in steps:
		var fade := 1.0 - float(i) / steps
		var shake := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * fade
		tween.tween_property(cam, "offset", shake, duration / steps)
	tween.tween_property(cam, "offset", Vector2.ZERO, duration / steps)

# One-off burst of square pixels, added next to `near` so it stays put in the level
func spawn_burst(near: Node, at: Vector2, color: Color) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = 14
	p.lifetime = 0.5
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 120.0
	p.gravity = Vector2(0, 300)
	p.scale_amount_min = 1.5
	p.scale_amount_max = 2.5
	p.color = color
	p.z_index = 6
	near.get_parent().add_child(p)
	p.global_position = at
	p.finished.connect(p.queue_free)
	p.emitting = true

func format_time(seconds: float) -> String:
	return "%d:%04.1f" % [floori(seconds / 60.0), fmod(seconds, 60.0)]

func load_next_level():
	if is_last_level():
		return
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
	shake_camera(player_ref, 4.0)
	spawn_burst(player_ref, player_ref.global_position, Color(1, 0.35, 0.35))
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
		get_tree().change_scene_to_file("res://scenes/GUI and Menus/died.tscn")

	player_ref.set("already_damaged", false)
