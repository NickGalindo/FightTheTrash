extends KinematicBody2D

#Physics constants
const ACCELERATION = 200
const MAX_SPEED = 100
const GRAVITY = 250
const FRICTION = 0.2

#Control Variables
var motion = Vector2.ZERO
var is_flying = false
var is_attacking = false
var is_damaged = false
var health = 40
var target = null

#Load objects
onready var bat_sprite = $BatSprite
onready var attack_area_collider = $AttackArea/AttackAreaCollider

func calculate_movement(delta: float):
	if bat_sprite.animation == "Dead":
		motion.y += GRAVITY*delta
	
	if is_damaged:
		return
	
	if target:
		motion.x += ((target.global_position.x-self.global_position.x)/abs(target.global_position.x-self.global_position.x))*ACCELERATION*delta
		motion.y += ((target.global_position.y-self.global_position.y)/abs(target.global_position.y-self.global_position.y))*ACCELERATION*delta
		
		motion = motion.clamped(MAX_SPEED)
		bat_sprite.flip_h= motion.x < 0
	else:
		motion.x = lerp(motion.x, 0, FRICTION)
		motion.y = lerp(motion.x, 0, FRICTION)

func animation_handler():
	if is_damaged:
		return
		
	if is_attacking:
		bat_sprite.play("Attack")
		return
	if is_flying:
		bat_sprite.play("Flying")
		return
	
	bat_sprite.play("Idle")

func apply_movement():
	if bat_sprite.animation == "Dead":
		motion = move_and_slide(motion, Vector2.UP)
	else:
		motion = move_and_slide(motion)

func _process(delta: float) -> void:
	if is_attacking:
		if bat_sprite.frame == 5:
			attack_area_collider.disabled = false
			return
		if bat_sprite.frame == 7:
			attack_area_collider.disabled = true
			return

func _physics_process(delta: float) -> void:
	calculate_movement(delta)
	apply_movement()
	animation_handler()


func _on_PatrolArea_area_entered(area: Area2D) -> void:
	if target:
		return
		
	if area.name == "PlayerHitbox":
		target = area
		is_flying = true

func _on_PatrolArea_area_exited(area: Area2D) -> void:
	if area.name == "PlayerHitbox":
		is_flying = false
		target = null


func _on_AttackAreaPatrol_area_entered(area: Area2D) -> void:
	if is_damaged:
		return
		
	if area.name == "PlayerHitbox":
		is_attacking = true

func _on_BatSprite_animation_finished() -> void:
	if bat_sprite.animation == "Dead":
		get_parent().bat_death()
		queue_free()
		return
	if bat_sprite.animation == "Damaged":
		is_damaged = false
		if health <= 0:
			bat_sprite.play("Dead")
			bat_sprite.offset = Vector2(0, -10)
			is_damaged = true
	return

func _on_AttackAreaPatrol_area_exited(area: Area2D) -> void:
	is_attacking = false


func _on_BatHitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_swing_attack") and not is_damaged:
		bat_sprite.play("Damaged")
		health -= 35
		is_damaged = true
		if is_attacking:
			is_attacking = false
			attack_area_collider.disabled = true
		return
	if area.is_in_group("player_chop_attack") and not is_damaged:
		bat_sprite.play("Damaged")
		health -= 50
		is_damaged = true
		if is_attacking:
			is_attacking = false
			attack_area_collider.disabled = true
		return
