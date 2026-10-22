extends Control
@onready var animation_player: AnimationPlayer = $Label/AnimationPlayer

func _ready():
	# Quitting does nothing useful in a browser tab
	if OS.has_feature("web"):
		$VBoxContainer/Exit.hide()
	animation_player.play("typing")
	await animation_player.animation_finished
	animation_player.play("idle")

func _on_start_game_pressed() -> void:
	PlayerUtils.current_level = 1
	PlayerUtils.reload_current_level()


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GUI and Menus/shop_menu.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	pass # Replace with function body.
