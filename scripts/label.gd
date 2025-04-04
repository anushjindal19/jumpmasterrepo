extends Label

var score = 0

@onready var label: Label = $"."

func add_point_pineapple():
	score += 300
	label.text = str(score)

func add_point_strawberry():
	score += 500
	label.text = str(score)

func add_point_cherry():
	score += 800
	label.text = str(score)

func add_point_banana():
	score += 200
	label.text = str(score)

func add_point_apple():
	score += 100
	label.text = str(score)

func _ready():
	add_to_group("scorelabel")
