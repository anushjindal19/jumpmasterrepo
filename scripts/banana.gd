extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var score_label: Label = get_tree().get_first_node_in_group("scorelabel")


func _on_body_entered(_body):
	score_label.add_point_banana()
	collision_mask &= ~((1 << 1) | (1 << 2))
	anim.play("collected")
	await anim.animation_finished
	queue_free()
