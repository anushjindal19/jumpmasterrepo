extends Area2D

@onready var anim_sprite = $AnimatedSprite2D  # Adjust path if needed
@export var is_starting_checkpoint: bool = false  # Determines if it's the first checkpoint
@export var is_ending_checkpoint: bool = false 
var checkpoint_activated = false  # Tracks if the checkpoint was already activated

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		var killzone = get_tree().get_first_node_in_group("killzone")  # Find KillZone
		if killzone:
			killzone.checkpoint_position = global_position  # Update checkpoint position
		var spikes = get_tree().get_nodes_in_group("spikes")  # Get all spikes
		for spike in spikes:
			spike.checkpoint_position = global_position


			# Handle different animations for the first checkpoint vs normal checkpoints
		if is_starting_checkpoint:
			anim_sprite.play("interacted")
		elif is_ending_checkpoint:
			anim_sprite.play("interacted")
			await anim_sprite.animation_looped
			get_tree().change_scene_to_file("res://scenes/level_2.tscn")
		else:
			if not checkpoint_activated:
				checkpoint_activated = true
				anim_sprite.play("checkpoint_reach")  # First-time animation
				await anim_sprite.animation_finished  # Wait for it to finish
			anim_sprite.play("flag_out")  # Default animation after first time
