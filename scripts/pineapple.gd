extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var score_label: Label = $"../../../CharacterBody2D/Camera2D/ScoreLabel"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var has_interacted = false

func _on_body_entered(body):
	if has_interacted or not body.is_in_group("player"):
		return
	else:
		has_interacted = true
		score_label.add_point_pineapple()
		audio_stream_player_2d.play()
		anim.play("collected")
		await anim.animation_finished
		queue_free()
