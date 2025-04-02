extends Label

var score = 0

@onready var label: Label = $"."

func add_point_pineapple():
	score += 1
	label.text = "Total Points: " + str(score)

func add_point_strawberry():
	score += 3
	label.text = "Total Points: " + str(score)

func add_point_cherry():
	score += 8
	label.text = "Total Points: " + str(score)

func add_point_banana():
	score += 2
	label.text = "Total Points: " + str(score)

func add_point_apple():
	score += 5
	label.text = "Total Points: " + str(score)

func _ready():
	add_to_group("scorelabel")
