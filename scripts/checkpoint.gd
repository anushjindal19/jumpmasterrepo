extends Area2D
@onready var anim_sprite = $AnimatedSprite2D  # Adjust path if needed
@export var is_starting_checkpoint: bool = false  # Determines if it's the first checkpoint
@export var is_ending_checkpoint: bool = false 
var checkpoint_activated = false  # Tracks if the checkpoint was already activated

func _enter_tree():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.checkpoint_position = global_position  # Where damage_player respawns the player
		# Handle different animations
		if is_starting_checkpoint:
			anim_sprite.play("interacted")
		elif is_ending_checkpoint:
			if checkpoint_activated:
				return
			checkpoint_activated = true
			PlayerUtils.finish_level()
			anim_sprite.play("interacted")
			var tree = get_tree()
			await anim_sprite.animation_looped
			tree.change_scene_to_file("res://scenes/GUI and Menus/next_level.tscn")
		else:
			if not checkpoint_activated:
				checkpoint_activated = true
				anim_sprite.play("checkpoint_reach")
				await anim_sprite.animation_finished
			anim_sprite.play("flag_out")
