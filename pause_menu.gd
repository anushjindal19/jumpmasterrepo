extends Control

@onready var bluranim: AnimationPlayer = $AnimationPlayer

func _ready():
	bluranim.play("RESET")

func resume():
	get_tree().paused = false
	bluranim.play_backwards("blur")
	await bluranim.animation_finished
	hide()

func pause():
	get_tree().paused = true
	show()
	bluranim.play("blur")
	await bluranim.animation_finished
	

func testEsc():
	if Input.is_action_just_pressed("escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused == true:
		resume()

func _on_resume_pressed():
	resume()

func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

func _process(_delta):
	testEsc()
