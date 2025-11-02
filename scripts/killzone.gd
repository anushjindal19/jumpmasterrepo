extends Area2D

@export var checkpoint_position: Vector2  # Stores the last checkpoint position
@onready var character_body_2d: CharacterBody2D = %CharacterBody2D
@onready var anim: AnimatedSprite2D = character_body_2d.find_child("AnimatedSprite2D", true, false)
@onready var life_container: HBoxContainer = $"../CharacterBody2D/Camera2D/lifeContainer"

func _ready():
	# Set the initial checkpoint to the starting position
	checkpoint_position = $"../checkpoints/first checkpoint".position  # Adjust path if needed
	add_to_group("killzone")
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		PlayerUtils.damage_player(
			body,
			body.anim,
			body.life_container,
			body.checkpoint_position
	)
