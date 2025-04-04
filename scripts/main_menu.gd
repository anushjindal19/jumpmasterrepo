extends Control
@onready var animation_player: AnimationPlayer = $Label/AnimationPlayer

func _ready():
	animation_player.play("typing")
	await animation_player.animation_finished
	animation_player.play("idle")

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level 1.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_levels_pressed() -> void:
	pass # Replace with function body.
