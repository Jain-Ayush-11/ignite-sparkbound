extends Node2D

@onready var moving_platform: AnimatableBody2D = $"."
@onready var button_right: Area2D = $ButtonRight
@onready var button_left: Area2D = $ButtonLeft
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D

var player: CharacterBody2D

const HEAT_FOR_MOVEMENT: float = 0.1

enum PLATFORM_DIRECTION {LEFT, RIGHT, NONE}

var platform_movement_direction: PLATFORM_DIRECTION = PLATFORM_DIRECTION.NONE
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	area.body_exited.connect(_on_area_2d_body_exited)
	animation_player.play("move")
	animation_player.pause()

func _physics_process(delta: float) -> void:
	var is_movement_key_pressed = false
	if Input.is_action_pressed("transfer_heat"):
		is_movement_key_pressed = true
	check_platform_movement(is_movement_key_pressed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ENTERED")
	if body.is_in_group("player"):
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	print("EXITED")
	if body.is_in_group("player"):
		player = null


func check_platform_movement(is_movement_key_pressed: bool) -> void:
	if not player or player.heat() <= 0 or !is_movement_key_pressed:
		platform_movement_direction = PLATFORM_DIRECTION.NONE
	else:
		if button_right.is_pressed:
			if animation_player.current_animation != " " and animation_player.current_animation_position >= animation_player.current_animation_length:
				platform_movement_direction = PLATFORM_DIRECTION.NONE
			else:
				platform_movement_direction = PLATFORM_DIRECTION.RIGHT
		elif button_left.is_pressed:
			if animation_player.current_animation_position == animation_player.current_animation_length:
				animation_player.seek(animation_player.current_animation_length - 0.001)
			platform_movement_direction = PLATFORM_DIRECTION.LEFT
		else:
			platform_movement_direction = PLATFORM_DIRECTION.NONE
	
	move_platform()


func move_platform() -> void:
	var move_and_update_platform: bool = false

	match platform_movement_direction:
		PLATFORM_DIRECTION.RIGHT:
			animation_player.speed_scale = 1
			move_and_update_platform = true
		PLATFORM_DIRECTION.LEFT:
			animation_player.speed_scale = -1
			move_and_update_platform = true
		PLATFORM_DIRECTION.NONE:
			animation_player.pause()
			move_and_update_platform = false
	
	if move_and_update_platform:
		animation_player.play()
		player.use_heat(HEAT_FOR_MOVEMENT)
