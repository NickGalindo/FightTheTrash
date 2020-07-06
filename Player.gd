extends KinematicBody2D

#Physics Constants
const ACCELERATION = 612
const MAX_SPEED = 150
const AIR_FRICTION = 0.001
const FRICTION = 0.15
const SLIDE_FRICTION = 0.01
const GRAVITY = 250
const JUMP_FORCE = 190

#Control variables
var motion = Vector2.ZERO
var is_sliding = false
var jump_status = "NONE"
var is_attacking = false
var health = 300

#Load Objects
onready var sprite = $Sprite
onready var standard_enviornment_collider = $StandardEnviornmentCollider
onready var slide_enviornment_collider = $SlideEnviorenmentCollider
onready var swing_attack_collider = $SwingAttackArea/SwingAttackAreaCollider
onready var chop_attack_collider = $ChopAttackArea/ChopAttackAreaCollider

func calculate_movement(x_input, y_input, delta: float):
	var current_motion_y_state = motion.y
	motion.y += GRAVITY*delta
		
	if x_input != 0 and y_input >= 0:
		if y_input >= 0:
			motion.x += x_input*ACCELERATION*delta
			motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
		if sprite.flip_h:
			swing_attack_collider.position.x = -abs(swing_attack_collider.position.x)
			chop_attack_collider.position.x = -abs(chop_attack_collider.position.x)
		else:
			swing_attack_collider.position.x = abs(swing_attack_collider.position.x)
			chop_attack_collider.position.x = abs(chop_attack_collider.position.x)
	
	if abs(current_motion_y_state) <= 5:
		if y_input < 0:
			is_sliding = true
			motion.x = lerp(motion.x, 0, SLIDE_FRICTION)
		else:
			is_sliding = false
			if x_input == 0 and jump_status == "NONE":
				motion.x = lerp(motion.x, 0, FRICTION)
		
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE
	else:
		is_sliding = false;
		if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:
			motion.y = -JUMP_FORCE/2
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_FRICTION)

func apply_movement():
	motion = move_and_slide(motion, Vector2.UP)
	
func animation_handler(x_input, y_input):
	if Input.is_action_just_pressed("Chop"):
		standard_enviornment_collider.disabled = false
		slide_enviornment_collider.disabled = true
		sprite.offset = Vector2(6, 0)
		is_attacking = true
		sprite.play("Chop")
		return
	
	if Input.is_action_just_pressed("Swing"):
		standard_enviornment_collider.disabled = false
		slide_enviornment_collider.disabled = true
		swing_attack_collider.disabled = false
		sprite.offset = Vector2(4, 0)
		is_attacking = true
		sprite.play("Swing")
		return
	
	if is_attacking:
		return
			
	if motion.y > 5:
		jump_status = "DOWN"
		sprite.play("Fall")
		return
	if motion.y < -5 or jump_status == "UP":
		jump_status = "UP"
		sprite.play("JumpUp")
		return
	
	jump_status = "NONE"
	
	if is_sliding:
		slide_enviornment_collider.disabled = false
		standard_enviornment_collider.disabled = true
		sprite.offset = Vector2(0, 5)
		sprite.play("Slide")
		return
	
	standard_enviornment_collider.disabled = false
	slide_enviornment_collider.disabled = true
	sprite.offset = Vector2.ZERO
		
	if x_input != 0:
		sprite.play("Run")
		return
	
	sprite.play("Idle")

func _physics_process(delta: float):
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_input = Input.get_action_strength("ui_up")-Input.get_action_strength("ui_down")
	
	calculate_movement(x_input, y_input, delta)
	apply_movement()
	animation_handler(x_input, y_input)
	
func _process(delta: float) -> void:
	if sprite.animation == "Chop":
		if sprite.frame >= 3:
			chop_attack_collider.disabled = false
		if sprite.frame >= 5:
			chop_attack_collider.disabled = true


func _on_Sprite_animation_finished():
	if sprite.animation == "Chop" or sprite.animation == "Swing":
		chop_attack_collider.disabled = true
		swing_attack_collider.disabled = true
		sprite.offset = Vector2(0, 0)
		is_attacking = false


func _on_PlayerHitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("skeleton_attack"):
		health -= 20
	if area.is_in_group("golem_attack"):
		health -= 5
	if area.is_in_group("bat_attack"):
		health -= 10
