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
	# Starting over erases the save, so ask first if there's anything to lose
	if PlayerUtils.has_save():
		$ConfirmNewGame.show()
	else:
		start_new_game()

func start_new_game() -> void:
	PlayerUtils.erase_save()
	PlayerUtils.play_level(1)

func _on_erase_pressed() -> void:
	start_new_game()

func _on_cancel_pressed() -> void:
	$ConfirmNewGame.hide()

func _unhandled_input(event):
	if event.is_action_pressed("escape") and $ConfirmNewGame.visible:
		$ConfirmNewGame.hide()


func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GUI and Menus/level_menu.tscn")


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GUI and Menus/shop_menu.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	pass # Replace with function body.
