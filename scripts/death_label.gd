extends Label


var deaths = 0

@onready var death_label: Label = $"."

func add_deathcount():
	deaths += 1
	death_label.text = "Total Deaths: " + str(deaths)
