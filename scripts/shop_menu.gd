extends Control

# One card per skin in ShopData.SKINS, copied from the hidden Template card (style it in the editor).
# The equipped skin's preview runs, the others idle, and skins you don't own are dimmed.

@onready var template: PanelContainer = $Cards/Template
@onready var points_label: Label = $Points
var cards := {}  # skin id -> card

func _ready():
	template.hide()
	for skin_id in ShopData.SKINS:
		var card: PanelContainer = template.duplicate()
		card.show()
		$Cards.add_child(card)
		cards[skin_id] = card
		card.get_node("VBox/Name").text = ShopData.SKINS[skin_id]["name"]
		card.get_node("VBox/Preview/Sprite").sprite_frames = ShopData.preview_frames(skin_id)
		card.get_node("VBox/Button").pressed.connect(_on_card_button_pressed.bind(skin_id))
	refresh()

func refresh() -> void:
	points_label.text = "Points: %d" % ShopData.points
	for skin_id in cards:
		var card: PanelContainer = cards[skin_id]
		var price: Label = card.get_node("VBox/Price")
		var button: Button = card.get_node("VBox/Button")
		var sprite: AnimatedSprite2D = card.get_node("VBox/Preview/Sprite")
		var owned := ShopData.owns(skin_id)
		sprite.modulate = Color.WHITE if owned else Color(0.45, 0.45, 0.45)
		if skin_id == ShopData.selected_skin:
			price.text = "OWNED"
			button.text = "Equipped"
			button.disabled = true
			sprite.play("run")
		elif owned:
			price.text = "OWNED"
			button.text = "Equip"
			button.disabled = false
			sprite.play("idle")
		else:
			price.text = "%d pts" % ShopData.SKINS[skin_id]["price"]
			button.text = "Buy"
			button.disabled = not ShopData.can_afford(skin_id)
			sprite.play("idle")

func _on_card_button_pressed(skin_id: String) -> void:
	if ShopData.owns(skin_id):
		ShopData.select(skin_id)
	else:
		ShopData.buy(skin_id)
	refresh()

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		_on_back_pressed()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GUI and Menus/main_menu.tscn")
