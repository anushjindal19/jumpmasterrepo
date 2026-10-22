extends Control
@onready var label: AnimationPlayer = $"YouBeatIt!/AnimationPlayer"

@onready var next_level_button: Button = $"PanelContainer/VBoxContainer/next level"

func _ready() -> void:
	if OS.has_feature("web"):
		$PanelContainer/VBoxContainer/quit.hide()
	# After the last level there's nowhere to go, so this becomes the end-of-game screen
	if PlayerUtils.is_last_level():
		$"YouBeatIt!".text = "GAME COMPLETE!"
		next_level_button.hide()
	show_stats()
	label.play("idle")
	await label.animation_finished
	$"YouBeatIt!".visible_characters = -1  # The typing animation stops at 13 characters
	label.play("bounce")

func show_stats() -> void:
	var text := "Score: %d   Best: %d
Time: %s   Best: %s" % [
		PlayerUtils.last_score, PlayerUtils.best_score,
		PlayerUtils.format_time(PlayerUtils.last_time), PlayerUtils.format_time(PlayerUtils.best_time)]
	if PlayerUtils.is_new_best_score and PlayerUtils.is_new_best_time:
		text += "
NEW BEST SCORE AND TIME!"
	elif PlayerUtils.is_new_best_score:
		text += "
NEW BEST SCORE!"
	elif PlayerUtils.is_new_best_time:
		text += "
NEW BEST TIME!"
	text += "
+%d shop points (%d to spend)" % [PlayerUtils.last_new_points, ShopData.points]
	$Stats.text = text

func _on_next_level_pressed() -> void:
	PlayerUtils.load_next_level()
	


func _on_restart_pressed() -> void:
	PlayerUtils.reload_current_level()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GUI and Menus/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
