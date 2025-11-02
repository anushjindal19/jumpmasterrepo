extends Control
@onready var label: AnimationPlayer = $"YouBeatIt!/AnimationPlayer"

func _ready() -> void:
	label.play("idle")
	await label.animation_finished
	label.play("bounce")

func _on_next_level_pressed() -> void:
	PlayerUtils.load_next_level()
	


func _on_restart_pressed() -> void:
	PlayerUtils.reload_current_level()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GUI and Menus/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
