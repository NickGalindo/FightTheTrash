extends KinematicBody2D

#Physics constants
const ACCELERATION = 200
const MAX_SPEED = 100
const GRAVITY = 250
const FRICTION = 0.3

#Control Variables
var motion = Vector2.ZERO
var is_walking = false
var is_attacking = false
var is_damaged = false
var health = 70

#Load objects
onready var golem_sprite = $GolumSprite
onready var find_ray_right = $FindRayRight
onready var find_ray_left = $FindRayLeft
onready var attack_ray = $AttackRay
onready var attack_area_collider = $AttackArea/AttackAreaCollider

func calculate_movement(delta: float):
	motion.y += GRAVITY*delta
	
	if is_damaged:
		return
	
	var direction = (-1 if find_ray_left.is_colliding() else 0) + (1 if find_ray_right.is_colliding() else 0)
	if direction != 0:
		motion.x += ACCELERATION*delta*direction
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		is_walking = true
		golem_sprite.flip_h = direction < 0
		if golem_sprite.flip_h:
			attack_ray.cast_to.x = -abs(attack_ray.cast_to.x)
			attack_area_collider.position.x = -abs(attack_area_collider.position.x)
		else:
			attack_ray.cast_to.x = abs(attack_ray.cast_to.x)
			attack_area_collider.position.x = abs(attack_area_collider.position.x)
	else:
		motion.x = lerp(motion.x, 0, FRICTION)
		is_walking = false

func animation_handler():
	if is_damaged:
		return
	if is_attacking:
		return
		
	if attack_ray.is_colliding():
		golem_sprite.play("Attack")
		is_attacking = true
		return
	
	if is_walking:
		golem_sprite.play("Walk")
		return
		
	golem_sprite.play("Idle")

func apply_movement():
	motion = move_and_slide(motion, Vector2.UP)

func _process(delta: float) -> void:
	if is_attacking:
		if golem_sprite.frame == 2:
			attack_area_collider.disabled = false
			return
		if golem_sprite.frame == 8:
			attack_area_collider.disabled = true
			return

func _physics_process(delta: float) -> void:
	calculate_movement(delta)
	apply_movement()
	animation_handler()

func _on_GolumSprite_animation_finished() -> void:
	if golem_sprite.animation == "Attack":
		is_attacking = false
		attack_area_collider.disabled = true
		return
		
	if golem_sprite.animation == "Damaged":
		if is_attacking:
			is_attacking = false
			attack_area_collider.disabled = true
		if health <= 0:
			golem_sprite.play("Dead")
			return
		is_damaged = false
		return
	if golem_sprite.animation == "Dead":
		get_parent().golem_death()
		queue_free()


func _on_GolemHitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_swing_attack") and not is_damaged:
		golem_sprite.play("Damaged")
		health -= 35
		is_damaged = true
		if is_attacking:
			is_attacking = false
			attack_area_collider.disabled = true
		return
	if area.is_in_group("player_chop_attack") and not is_damaged:
		golem_sprite.play("Damaged")
		health -= 50
		is_damaged = true
		if is_attacking:
			is_attacking = false
			attack_area_collider.disabled = true
		return
