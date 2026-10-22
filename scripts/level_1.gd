extends Node2D

@onready var life_container: HBoxContainer = $CharacterBody2D/Camera2D/lifeContainer


func _ready() -> void:
	life_container.setMaxLifes(3)
	PlayerUtils.level_time = 0.0


func _process(delta):
	# Stops while paused. Divide out the damage slow-mo so the timer counts real seconds
	PlayerUtils.level_time += delta / Engine.time_scale
