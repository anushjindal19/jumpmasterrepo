extends Area2D

# Walks back and forth from where it was placed. Jump on it to kill it, touch it from the side and you get hurt.

@export var patrol_distance := 32.0  # How far it walks each way from its start position
@export var speed := 25.0
const STOMP_BOUNCE = -220.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var start_x := 0.0
var direction := -1  # The sprites face left
var is_dead = false

func _ready():
	add_to_group("enemy")
	start_x = position.x
	body_entered.connect(_on_body_entered)
	anim.play("run")

func _physics_process(delta):
	if is_dead:
		return
	position.x += direction * speed * delta
	if position.x <= start_x - patrol_distance:
		direction = 1
	elif position.x >= start_x + patrol_distance:
		direction = -1
	anim.flip_h = direction > 0

func _on_body_entered(body):
	if is_dead or not body.is_in_group("player"):
		return
	# A stomp is the player falling onto it from above. Anything else hurts the player
	if body.velocity.y > 0 and body.global_position.y < global_position.y - 6:
		stomp(body)
	else:
		PlayerUtils.damage_player(body, body.anim, body.life_container, body.checkpoint_position)

func stomp(player):
	is_dead = true
	player.velocity.y = STOMP_BOUNCE
	player.can_double_jump = true
	player.is_double_jumping = false
	set_deferred("monitoring", false)
	PlayerUtils.shake_camera(player, 2.0, 0.15)
	PlayerUtils.spawn_burst(self, global_position, Color.WHITE)
	anim.play("hit")
	await anim.animation_finished
	queue_free()
