extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	anim.play("fade_in")
	await anim.animation_finished

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/level 1.tscn")


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_settings_pressed():
	pass


func _on_quit_pressed():
	get_tree().quit()
