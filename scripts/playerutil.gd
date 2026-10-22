# res://scripts/player_utils.gd
extends Node

const LAST_LEVEL := 3
const SAVE_PATH := "user://save.cfg"
const LEVEL_PATH := "res://scenes/level_%d.tscn"

signal score_changed(score: int)

var current_level := 1
var level_time := 0.0  # Seconds spent in the current level, counted by level_1.gd
var score := 0  # Fruit points collected in the current level, including fruit banked on earlier runs

# Fruit picked up this run that wasn't banked on an earlier run. Only saved if the level is finished,
# so quitting or dying mid-level leaves no trace
var new_fruit: Array = []
var new_fruit_points := 0
var _banked_fruit := {}  # Level number -> fruit paths saved in the save file, read on first use

# Results of the level that was just finished, shown on the next_level screen
var last_score := 0
var last_new_points := 0
var last_time := 0.0
var best_score := 0
var best_time := 0.0
var is_new_best_score := false
var is_new_best_time := false

func is_last_level() -> bool:
	return current_level >= LAST_LEVEL

# Called by each fruit when the player touches it
func collect_fruit(fruit: Node, points: int) -> void:
	score += points
	score_changed.emit(score)
	var id := fruit_id(fruit)
	if not is_fruit_banked(fruit) and id not in new_fruit:
		new_fruit.append(id)
		new_fruit_points += points

# A fruit's path inside its level, e.g. "fruits/apples/apple3". Renaming or moving it in the editor
# makes it count as a new fruit
func fruit_id(fruit: Node) -> String:
	return str(fruit.owner.get_path_to(fruit))

func is_fruit_banked(fruit: Node) -> bool:
	return fruit_id(fruit) in banked_fruit(level_number(fruit.owner))

func banked_fruit(level: int) -> Array:
	if not _banked_fruit.has(level):
		var save := ConfigFile.new()
		save.load(SAVE_PATH)
		_banked_fruit[level] = save.get_value("level_%d" % level, "collected_fruit", [])
	return _banked_fruit[level]

# Counts the fruit instances in a level without instancing it
func fruit_total(level: int) -> int:
	var state := (load(LEVEL_PATH % level) as PackedScene).get_state()
	var total := 0
	for i in state.get_node_count():
		var instance := state.get_node_instance(i)
		if instance and instance.resource_path.begins_with("res://scenes/fruits/"):
			total += 1
	return total

# "res://scenes/level_2.tscn" -> 2
func level_number(level_root: Node) -> int:
	return level_root.scene_file_path.get_file().get_basename().trim_prefix("level_").to_int()

# The highest level that can be played from the level menu
func unlocked_level() -> int:
	var save := ConfigFile.new()
	save.load(SAVE_PATH)
	if save.has_section_key("progress", "unlocked_level"):
		return save.get_value("progress", "unlocked_level")
	# Saves from before the level menu: unlock the level after the furthest one with a best score
	var unlocked := 1
	for level in range(1, LAST_LEVEL + 1):
		if save.has_section_key("level_%d" % level, "best_score"):
			unlocked = mini(level + 1, LAST_LEVEL)
	return unlocked

# Best score and time for the level menu. Empty if the level hasn't been finished
func level_record(level: int) -> Dictionary:
	var save := ConfigFile.new()
	save.load(SAVE_PATH)
	var section := "level_%d" % level
	if not save.has_section_key(section, "best_score"):
		return {}
	return {"best_score": save.get_value(section, "best_score"), "best_time": save.get_value(section, "best_time")}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# Wipes unlocks, collected fruit, best scores and times, shop points and skins
func erase_save() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	_banked_fruit.clear()
	ShopData.reset()

# Called by level_1.gd when a level (re)starts
func start_level(level_root: Node) -> void:
	current_level = level_number(level_root)  # Also right when a level is run straight from the editor
	level_time = 0.0
	score = 0
	new_fruit = []
	new_fruit_points = 0
	score_changed.emit(score)

# Records the run: best score and time, the fruit collected, the next level unlocked and the shop points
func finish_level() -> void:
	last_score = score
	last_new_points = new_fruit_points
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
	_banked_fruit[current_level] = banked_fruit(current_level) + new_fruit
	save.set_value(section, "collected_fruit", _banked_fruit[current_level])
	save.set_value("progress", "unlocked_level", maxi(unlocked_level(), mini(current_level + 1, LAST_LEVEL)))
	save.save(SAVE_PATH)
	new_fruit = []
	new_fruit_points = 0
	ShopData.add_points(last_new_points)  # Only fruit never banked before turns into shop points

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
	play_level(current_level + 1)

func play_level(level: int) -> void:
	current_level = level
	reload_current_level()

func reload_current_level():
	get_tree().change_scene_to_file(LEVEL_PATH % current_level)

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
