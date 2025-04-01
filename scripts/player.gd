extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var last_direction = Vector2.ZERO
const JUMP_VELOCITY = -300.0
const GRAVITY = 900
const WALL_JUMP_PUSHBACK = 1000
const WALL_SLIDE_GRAVITY = 50
var is_wall_sliding = false
var can_jump = true
var can_double_jump = true
var is_double_jumping = false  # Tracks if the double jump animation has been triggered

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump and double jump
	if Input.is_action_just_pressed("jump") and can_jump:
		if is_on_wall() and Input.is_action_pressed("right"):
			velocity.y = JUMP_VELOCITY
			velocity.x = -WALL_JUMP_PUSHBACK
			anim.play("jump")
			can_double_jump = true
			is_double_jumping = false
		elif is_on_wall() and Input.is_action_pressed("left"):
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSHBACK
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
			is_double_jumping = true  # Prevent playing double jump animation again
		elif can_double_jump and not is_double_jumping and not is_on_floor():
			velocity.y = JUMP_VELOCITY
			anim.play("double_jump")
			can_double_jump = false
			is_double_jumping = true
	elif is_on_floor() or is_on_wall():
		can_jump = true
		can_double_jump = true
		is_double_jumping = false

	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input = input.normalized()

	# Preserve vertical velocity
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
			last_direction = input
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
	if last_direction.x != 0 and anim.animation != "damagetaken":
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
