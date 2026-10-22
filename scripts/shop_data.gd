extends Node

# Shop state: points to spend, which skins are owned and which one is worn.
# Saved in the same file as the best scores, under [shop].

signal points_changed(points: int)

const CHARACTERS_DIR := "res://assets/sprites/assetpack/Main Characters/"
const DEFAULT_SKIN := "briar"
# "frames" is a SpriteFrames with the animations player.gd plays (128x128 frames, drawn at 1/3 scale).
# "icon" is the part of the first idle frame shown as a life in the HUD.
# The shop lists them in this order.
const SKINS := {
	"briar": {"name": "Briar", "frames": CHARACTERS_DIR + "Briar/briar_frames.tres", "icon": Rect2(34, 14, 56, 56), "price": 0},
	"ferro": {"name": "Ferro", "frames": CHARACTERS_DIR + "Ferro/ferro_frames.tres", "icon": Rect2(34, 32, 56, 56), "price": 2000},
	"wick": {"name": "Wick", "frames": CHARACTERS_DIR + "Wick/wick_frames.tres", "icon": Rect2(32, 30, 56, 56), "price": 4000},
}

var points := 0
var owned_skins: Array = [DEFAULT_SKIN]
var selected_skin := DEFAULT_SKIN

func _ready():
	reset()

# Reads the shop state from the save file. Called again after the save is erased
func reset() -> void:
	var save := ConfigFile.new()
	save.load(PlayerUtils.SAVE_PATH)  # Fails on the first run, which keeps the defaults
	points = save.get_value("shop", "points", 0)
	# Skins that have been removed from SKINS are dropped, and the default is always owned
	owned_skins = save.get_value("shop", "owned_skins", []).filter(func(s): return SKINS.has(s))
	if not owns(DEFAULT_SKIN):
		owned_skins.push_front(DEFAULT_SKIN)
	selected_skin = save.get_value("shop", "selected_skin", DEFAULT_SKIN)
	if not owns(selected_skin):
		selected_skin = DEFAULT_SKIN

func owns(skin_id: String) -> bool:
	return skin_id in owned_skins

func can_afford(skin_id: String) -> bool:
	return points >= SKINS[skin_id]["price"]

func add_points(amount: int) -> void:
	points += amount
	_save()
	points_changed.emit(points)

# Buys and equips a skin. Returns false if it's already owned or too expensive
func buy(skin_id: String) -> bool:
	if owns(skin_id) or not can_afford(skin_id):
		return false
	points -= SKINS[skin_id]["price"]
	owned_skins.append(skin_id)
	selected_skin = skin_id
	_save()
	points_changed.emit(points)
	return true

func select(skin_id: String) -> void:
	if owns(skin_id):
		selected_skin = skin_id
		_save()

func skin_frames(skin_id := selected_skin) -> SpriteFrames:
	return load(SKINS[skin_id]["frames"])

# The skin's head, for the lives in the HUD
func life_icon(skin_id := selected_skin) -> AtlasTexture:
	var icon := AtlasTexture.new()
	icon.atlas = skin_frames(skin_id).get_frame_texture("idle", 0).atlas
	icon.region = SKINS[skin_id]["icon"]
	return icon

func _save() -> void:
	var save := ConfigFile.new()
	save.load(PlayerUtils.SAVE_PATH)  # Keep the best scores already in the file
	save.set_value("shop", "points", points)
	save.set_value("shop", "owned_skins", owned_skins)
	save.set_value("shop", "selected_skin", selected_skin)
	save.save(PlayerUtils.SAVE_PATH)
