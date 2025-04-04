extends Node2D

@onready var life_container: HBoxContainer = $CharacterBody2D/Camera2D/lifeContainer

func _ready() -> void:
	life_container.setMaxLifes(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
