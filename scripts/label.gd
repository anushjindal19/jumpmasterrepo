extends Label

# Shows PlayerUtils.score, which the fruits add to

func _ready():
	text = str(PlayerUtils.score)
	PlayerUtils.score_changed.connect(_on_score_changed)

func _on_score_changed(score: int) -> void:
	text = str(score)
