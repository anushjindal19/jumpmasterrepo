extends Control

# One card per level, copied from the hidden Template card (style it in the editor).
# A level unlocks when the one before it is finished.

@onready var template: PanelContainer = $Cards/Template

func _ready():
	template.hide()
	var unlocked := PlayerUtils.unlocked_level()
	for level in range(1, PlayerUtils.LAST_LEVEL + 1):
		var card: PanelContainer = template.duplicate()
		card.show()
		$Cards.add_child(card)
		card.get_node("VBox/Name").text = "Level %d" % level
		var info: Label = card.get_node("VBox/Info")
		var button: Button = card.get_node("VBox/Button")
		if level > unlocked:
			card.modulate = Color(1, 1, 1, 0.5)
			info.text = "Finish level %d\nto unlock" % (level - 1)
			button.text = "Locked"
			button.disabled = true
			continue
		var record := PlayerUtils.level_record(level)
		var fruit := "Fruit: %d/%d" % [PlayerUtils.banked_fruit(level).size(), PlayerUtils.fruit_total(level)]
		if record.is_empty():
			info.text = "Not finished yet\n\n" + fruit
		else:
			info.text = "Best: %d\nTime: %s\n%s" % [record["best_score"], PlayerUtils.format_time(record["best_time"]), fruit]
		button.pressed.connect(PlayerUtils.play_level.bind(level))

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		_on_back_pressed()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GUI and Menus/main_menu.tscn")
