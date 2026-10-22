extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const JUMP_VELOCITY = -300.0
const GRAVITY = 900
const WALL_JUMP_PUSHBACK = 100
const WALL_JUMP_CONTROL_LOCK = 0.15  # Seconds after a wall jump where input can't override the push
const WALL_SLIDE_GRAVITY = 50
var wall_jump_timer = 0.0
var is_wall_sliding = false
var can_jump = true
var can_double_jump = true
var is_double_jumping = false  # Tracks if the double jump animation has been triggered
@onready var life_container: HBoxContainer = $Camera2D/lifeContainer
var checkpoint_position = Vector2.ZERO
var already_damaged = false

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump and double jump
	if Input.is_action_just_pressed("jump") and can_jump:
		$AudioStreamPlayer2D.play()
		if is_on_wall() and not is_on_floor():  # Wall jump, pushed away from the wall
			velocity.y = JUMP_VELOCITY
			velocity.x = get_wall_normal().x * WALL_JUMP_PUSHBACK
			wall_jump_timer = WALL_JUMP_CONTROL_LOCK
			anim.play("jump")
			can_double_jump = true
			is_double_jumping = false
		elif is_on_floor():  # Normal jump
			velocity.y = JUMP_VELOCITY
			anim.play("jump")  # Play normal jump animation
			can_double_jump = true
			is_double_jumping = false  # Reset double jump state when landing
		elif can_double_jump and not is_double_jumping:  # Double jump
			velocity.y = JUMP_VELOCITY
			anim.play("double_jump")  # Play double jump animation
			can_double_jump = false
			is_double_jumping = true
			can_jump = false  # Prevent playing double jump animation again
	elif is_on_floor() or is_on_wall():
		can_jump = true
		can_double_jump = true
		is_double_jumping = false

	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input = input.normalized()

	# Don't let input overwrite the wall jump push until the lock runs out
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	else:
		velocity.x = input.x * 100

	move_and_slide()

	# Animation Handling
	if not is_on_floor() and anim.animation != "damagetaken":
		if velocity.y < 0:  # Going up
			if is_double_jumping:
				anim.play("double_jump")  # Play only once
			else:
				anim.play("jump")
		elif velocity.y > 0:
			if anim.animation == "damagetaken":
				return
			else:
				anim.play("fall")
	else:
		is_double_jumping = false  # Reset when landing
		if input != Vector2.ZERO:
			play_movement_animation(input)
		else:
			play_idle_animation()
	wall_slide(delta)

	# Flip sprite based on direction
	if input.x > 0:
		anim.flip_h = false
	elif input.x < 0:
		anim.flip_h = true

func play_movement_animation(input):
	if input.x != 0 and anim.animation != "damagetaken":
		anim.play("run")

func play_idle_animation():
	if anim.animation != "damagetaken":
		anim.play("idle")
		
func _ready():
	add_to_group("player")

func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
		
	if is_wall_sliding:
		velocity.y += (WALL_SLIDE_GRAVITY * delta)
		velocity.y = min(velocity.y, WALL_SLIDE_GRAVITY)
		can_jump = true
		if anim.animation != "damagetaken":
			anim.play("wall_idle")
