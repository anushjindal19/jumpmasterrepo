extends Node2D

@onready var life_container: HBoxContainer = $HUD/lifeContainer


func _ready() -> void:
	life_container.setMaxLifes(3)
	PlayerUtils.start_level(self)


func _process(delta):
	# Stops while paused. Divide out the damage slow-mo so the timer counts real seconds
	PlayerUtils.level_time += delta / Engine.time_scale
