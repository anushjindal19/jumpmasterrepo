extends Area2D

func _ready():
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
