extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var score_label: Label = $"../../CharacterBody2D/Camera2D/ScoreLabel"

func _ready():
	add_to_group("fruits")

func _on_body_entered(_body):
	score_label.add_point_pineapple()
	collision_mask &= ~(1 << 2)
	anim.play("collected")
	await anim.animation_finished
	queue_free()
