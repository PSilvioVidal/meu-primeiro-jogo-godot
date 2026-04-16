extends CharacterBody2D

const SPEED: float = 180.0
const JUMP_VELOCITY: float = -320.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction: float = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	if not is_on_floor():
		anim.play("jump")
	elif direction != 0:
		anim.play("walk")
	else:
		anim.play("idle")

	move_and_slide()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	print("player morreu")

	# para o personagem completamente
	set_physics_process(false)
	set_process(false)
	velocity = Vector2.ZERO

	# desativa colisão para não morrer de novo
	if collision:
		collision.disabled = true

	# toca a animação só uma vez
	if anim.sprite_frames.has_animation("dead"):
		anim.play("dead")
		await anim.animation_finished

	await get_tree().create_timer(0.2).timeout
	get_tree().reload_current_scene()

func bounce() -> void:
	if is_dead:
		return
	velocity.y = -260
