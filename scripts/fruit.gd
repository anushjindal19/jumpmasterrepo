extends Area2D

# Shared by every fruit scene. Set `points` on the scene's root node.

@export var points := 100

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")  # Not every fruit has one
var has_interacted = false

func _on_body_entered(body):
	if has_interacted or not body.is_in_group("player"):
		return
	has_interacted = true
	PlayerUtils.add_score(points)
	if sound:
		sound.play()
	anim.play("collected")
	await anim.animation_finished
	queue_free()
