extends Control
@onready var animation_player: AnimationPlayer = $Label/AnimationPlayer

func _ready():
	animation_player.play("idle")

func _on_start_game_pressed() -> void:
	PlayerUtils.reload_current_level()


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	pass # Replace with function body.
