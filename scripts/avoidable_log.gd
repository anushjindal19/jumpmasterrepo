extends StaticBody2D

@export var checkpoint_position: Vector2
@onready var character_body_2d: CharacterBody2D = $"../../CharacterBody2D"
@onready var anim: AnimatedSprite2D = character_body_2d.find_child("AnimatedSprite2D", true, false)
@onready var life_container: HBoxContainer = $"../../CharacterBody2D/Camera2D/lifeContainer"
@onready var animated_spike: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var spike_frames = [8]
@onready var walkway: CollisionShape2D = $walkway

var body_inside = false
var player_ref: CharacterBody2D = null
var already_damaged = false

func _ready():
	checkpoint_position = $"../../checkpoints/first checkpoint".position
	add_to_group("spikes")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body_inside = true
		player_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_ref:
		body_inside = false
		player_ref = null
		already_damaged = false

func _process(_delta):
	if body_inside and player_ref and animated_spike.frame in spike_frames and not already_damaged:
		if player_ref.is_in_group("player"):
			PlayerUtils.damage_player(
				player_ref,
				player_ref.anim,
				player_ref.life_container,
				player_ref.checkpoint_position
			)
		already_damaged = true
