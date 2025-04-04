extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var score_label: Label = $"../../../CharacterBody2D/Camera2D/ScoreLabel"
var has_interacted = false

func _on_body_entered(_body):
	if has_interacted:
		return
	else:
		has_interacted = true
		score_label.add_point_apple()
		anim.play("collected")
		await anim.animation_finished
		queue_free()
