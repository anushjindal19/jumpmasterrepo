extends Label

var score = 0

@onready var label: Label = $"."

func add_point_pineapple():
	score += 2
	label.text = "Total Points: " + str(score)

func _ready():
	add_to_group("scorelabel")
