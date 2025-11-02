extends HBoxContainer

@onready var LifeGuiClass = preload("res://scenes/GUI and Menus/life_gui.tscn")

func setMaxLifes(_max: int):
	for i in range(_max):
		var life = LifeGuiClass.instantiate()
		add_child(life)

func reduce_life():
	if get_child_count() > 0:
		remove_child(get_child(get_child_count() - 1))
