extends Camera2D

# Follows the player sideways, but only moves up or down when the player lands on a higher or lower
# floor, or would otherwise leave the screen. Ordinary jumps don't bob the view.
# Sits under the player in each level, but positions itself in world space.

@export var horizontal_speed := 6.0  # How quickly the camera catches up sideways (higher = snappier)
@export var vertical_speed := 3.0  # How quickly it settles on a new floor height
@export var look_ahead := 24.0  # Pixels shown ahead of the way the player is facing
@export var up_margin := 56.0  # How far above the last floor the player can go before the camera follows
@export var down_margin := 16.0  # Same below, smaller so you can see where you're falling
const SNAP_DISTANCE := 200.0  # Teleports (respawns) further than this snap instead of panning

@onready var player: CharacterBody2D = get_parent()
var follow_offset := Vector2.ZERO  # Where the camera sits relative to the player, from the level
var floor_y := 0.0  # Camera height for the floor the player last stood on
var smooth_floor_y := 0.0  # floor_y eased over time, so stepping onto a new floor pans gently
var facing := 1.0

func _ready():
	follow_offset = position
	top_level = true
	process_callback = CAMERA2D_PROCESS_PHYSICS
	snap()

func snap() -> void:
	var target := player.global_position + follow_offset
	floor_y = target.y
	smooth_floor_y = target.y
	global_position = target
	reset_smoothing()

func _physics_process(delta):
	var target := player.global_position + follow_offset
	if target.distance_to(global_position) > SNAP_DISTANCE:
		snap()
		return

	if player.velocity.x != 0:
		facing = signf(player.velocity.x)
	var x := target.x + facing * look_ahead

	if player.is_on_floor():
		floor_y = target.y
	smooth_floor_y = lerpf(smooth_floor_y, floor_y, 1.0 - exp(-vertical_speed * delta))

	global_position.x = lerpf(global_position.x, x, 1.0 - exp(-horizontal_speed * delta))
	# The margins are a hard edge, so a long fall or a high wall climb never leaves the screen
	global_position.y = clampf(smooth_floor_y, target.y - down_margin, target.y + up_margin)
