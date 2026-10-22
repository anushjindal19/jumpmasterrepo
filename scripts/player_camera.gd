extends Camera2D

# The bottom of the view rests on the level's CameraFloor line (a Line2D in the "camera_floor" group),
# so the camera doesn't bob with jumps. When the player stands on a platform too high to fit above that
# line, the camera zooms out to show both. It only drops below the line when the player does (falling off).
# Horizontally it shows more of the level in the direction the player is running.
# Sits under the player in each level, but positions itself in world space.

@export var base_zoom := 4.0
@export var min_zoom := 2.0  # The furthest it zooms out
@export var headroom := 72.0  # Space kept above the head of a standing player (a single jump is 50 px)
@export var look_ahead := 0.2  # Extra view in the running direction, as a fraction of the view width
@export var horizontal_speed := 3.0  # How quickly each part catches up (higher = snappier)
@export var vertical_speed := 4.0
@export var zoom_speed := 2.5
const FEET := 15.0  # Player origin to the bottom of the collision shape
const HEIGHT := 24.0  # Feet to the top of the head, roughly
const EDGE := 8.0  # Mid-air, the player never gets closer than this to the top or bottom of the view
const SNAP_DISTANCE := 300.0  # Teleports (respawns) further than this snap instead of panning

@onready var player: CharacterBody2D = get_parent()
var floor_points := PackedVector2Array()  # CameraFloor points in world space, left to right
var stand_y := 0.0  # Feet height of the floor the player last stood on
var facing := 1.0
var view_bottom := 0.0  # World y of the bottom edge of the view
var view_height := 0.0  # World pixels from the bottom edge to the top edge

func _ready():
	top_level = true
	process_callback = CAMERA2D_PROCESS_PHYSICS
	var line: Line2D = get_tree().get_first_node_in_group("camera_floor")
	if line:
		line.hide()  # Only drawn in the editor
		for p in line.points:
			floor_points.append(line.to_global(p))
		var sorted := Array(floor_points)
		sorted.sort_custom(func(a, b): return a.x < b.x)
		floor_points = PackedVector2Array(sorted)
	snap()

# Bottom edge of the view at a given x, from the CameraFloor line
func floor_at(x: float) -> float:
	if floor_points.is_empty():
		return stand_y + 24.0  # No line in this level: just keep the last floor near the bottom
	if x <= floor_points[0].x:
		return floor_points[0].y
	for i in range(1, floor_points.size()):
		if x <= floor_points[i].x:
			var a := floor_points[i - 1]
			var b := floor_points[i]
			return lerpf(a.y, b.y, (x - a.x) / maxf(b.x - a.x, 0.001))
	return floor_points[-1].y

func snap() -> void:
	stand_y = player.global_position.y + FEET
	var target := _target()
	global_position.x = target.x
	view_bottom = target.y
	view_height = target.z
	_apply()
	reset_smoothing()

# x, bottom edge and height the view is heading for
func _target() -> Vector3:
	var screen := get_viewport_rect().size
	var base_height := screen.y / base_zoom
	var width := screen.x * maxf(view_height, base_height) / screen.y  # Current view width in world pixels
	var x := player.global_position.x + facing * look_ahead * width
	# Never rest above the floor the player is standing on, e.g. a low area the line doesn't cover
	var bottom := maxf(floor_at(x), stand_y + 24.0)
	var needed := bottom - (stand_y - HEIGHT - headroom)
	var height := clampf(needed, base_height, screen.y / min_zoom)
	return Vector3(x, bottom, height)

func _physics_process(delta):
	if player.global_position.distance_to(get_screen_center_position()) > SNAP_DISTANCE:
		snap()
		return
	if player.velocity.x != 0:
		facing = signf(player.velocity.x)
	if player.is_on_floor():
		stand_y = player.global_position.y + FEET

	var target := _target()
	global_position.x = lerpf(global_position.x, target.x, 1.0 - exp(-horizontal_speed * delta))
	view_bottom = lerpf(view_bottom, target.y, 1.0 - exp(-vertical_speed * delta))
	view_height = lerpf(view_height, target.z, 1.0 - exp(-zoom_speed * delta))

	# Mid-air the player must stay on screen: big jumps lift the view, falling off drags it down
	var feet := player.global_position.y + FEET
	view_bottom = maxf(view_bottom, feet + EDGE)
	view_bottom = minf(view_bottom, feet - HEIGHT - EDGE + view_height)
	# Same sideways, in case the player outruns the easing
	var screen := get_viewport_rect().size
	var half_width := screen.x * view_height / screen.y / 2.0 - 24.0
	global_position.x = clampf(global_position.x, player.global_position.x - half_width, player.global_position.x + half_width)
	_apply()

func _apply() -> void:
	var z := get_viewport_rect().size.y / view_height
	zoom = Vector2(z, z)
	global_position.y = view_bottom - view_height / 2.0
