extends Node

# Shop state: points to spend, which skins are owned and which one is worn.
# Saved in the same file as the best scores, under [shop].

signal points_changed(points: int)

const CHARACTERS_DIR := "res://assets/sprites/assetpack/Main Characters/"
const DEFAULT_SKIN := "ninja_frog"
# Every character in the Pixel Adventure pack has the same sprite sheets, so a skin is just a folder.
# The shop lists them in this order.
const SKINS := {
	"ninja_frog": {"name": "Ninja Frog", "folder": "Ninja Frog", "price": 0},
	"pink_man": {"name": "Pink Man", "folder": "Pink Man", "price": 2000},
	"mask_dude": {"name": "Mask Dude", "folder": "Mask Dude", "price": 4000},
	"virtual_guy": {"name": "Virtual Guy", "folder": "Virtual Guy", "price": 6000},
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
	owned_skins = save.get_value("shop", "owned_skins", [DEFAULT_SKIN])
	selected_skin = save.get_value("shop", "selected_skin", DEFAULT_SKIN)
	# A skin that's been removed from SKINS falls back to the default
	if not SKINS.has(selected_skin) or not owns(selected_skin):
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

# Returns a copy of the player's animations with every frame taken from the skin's sheets instead
func skin_frames(base: SpriteFrames, skin_id := selected_skin) -> SpriteFrames:
	if skin_id == DEFAULT_SKIN:
		return base
	var folder: String = CHARACTERS_DIR + SKINS[skin_id]["folder"] + "/"
	var frames: SpriteFrames = base.duplicate()
	for anim_name in frames.get_animation_names():
		for i in frames.get_frame_count(anim_name):
			var old: AtlasTexture = frames.get_frame_texture(anim_name, i)
			var tex := AtlasTexture.new()
			tex.atlas = load(folder + old.atlas.resource_path.get_file())
			tex.region = old.region
			frames.set_frame(anim_name, i, tex, frames.get_frame_duration(anim_name, i))
	return frames

# Idle and run animations for the shop's preview of a skin
func preview_frames(skin_id: String) -> SpriteFrames:
	var folder: String = CHARACTERS_DIR + SKINS[skin_id]["folder"] + "/"
	var frames := SpriteFrames.new()
	for anim_name in ["idle", "run"]:
		var sheet: Texture2D = load(folder + anim_name.capitalize() + " (32x32).png")
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, 12 if anim_name == "idle" else 16)  # Same as player.tscn
		for x in range(0, sheet.get_width(), 32):
			var tex := AtlasTexture.new()
			tex.atlas = sheet
			tex.region = Rect2(x, 0, 32, 32)
			frames.add_frame(anim_name, tex)
	return frames

func _save() -> void:
	var save := ConfigFile.new()
	save.load(PlayerUtils.SAVE_PATH)  # Keep the best scores already in the file
	save.set_value("shop", "points", points)
	save.set_value("shop", "owned_skins", owned_skins)
	save.set_value("shop", "selected_skin", selected_skin)
	save.save(PlayerUtils.SAVE_PATH)
