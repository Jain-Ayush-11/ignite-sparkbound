class_name Player extends CharacterBody2D

signal shape_switch_request(shape, is_input_wrong)

class PlayerShape:
	var weight: int
	var speed: int
	var jump_velocity: int
	var can_wall_jump: bool
	var can_transfer_heat: bool

	func _init(
		weight: int,
		speed: int,
		jump_velocity: int,
		can_transfer_heat: bool = false,
		can_wall_jump: bool = false
	) -> void:
		self.weight = weight
		self.speed = speed
		self.jump_velocity = jump_velocity
		self.can_transfer_heat = can_transfer_heat
		self.can_wall_jump = can_wall_jump

enum SHAPE {CIRCLE, SQUARE, TRIANGLE, INVALID}

var current_shape = null
var next_shape = null

var circle = PlayerShape.new(50, 300, -350, false, false)
var square = PlayerShape.new(100, 50, -100, true, false)
var triangle = PlayerShape.new(5, 100, -400, false, true)

var shape_properties: Dictionary[SHAPE, PlayerShape] = {
	SHAPE.CIRCLE: circle,
	SHAPE.SQUARE: square,
	SHAPE.TRIANGLE: triangle
}

var can_wall_jump: bool = false
var is_wall_jumping: bool = false
var wall_jump_timer_start: float
var wall_jump_collider_direction: int

var is_movement_allowed: bool = true

var _heat: float = GameState.player_heat
const MAX_PLAYER_HEAT: float = 100.0
const MIN_PLAYER_HEAT: float = 0.0

const JUMP_WALL_LAYER: int = 16

const WALL_JUMP_KNOCKBACK: float = 1000
const WALL_JUMP_VELOCITY: float = -400
const WALL_JUMP_TIME_OFFSET: float = 0.1

const CIRCLE_SQUARE_SWITCH_KEY = "Q"
const CIRCLE_TRIANGLE_SWITCH_KEY = "E"

@onready var player_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape_switch_timer: Timer = $ShapeSwitchTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const collision_shape_paths: Dictionary[SHAPE, String] = {
	SHAPE.CIRCLE: "res://Shapes/Player/player_circle_collision_shape.tres",
	SHAPE.SQUARE: "res://Shapes/Player/player_square_collision_shape.tres",
	SHAPE.TRIANGLE: "res://Shapes/Player/player_triangle_collision_shape.tres"
}


func _input(event: InputEvent) -> void:
	var target_shape = null
	if event.is_action_pressed("switch_shape"):
		if !shape_switch_timer.is_stopped():
			print("WAIT")
			return
		match event.as_text():
			CIRCLE_SQUARE_SWITCH_KEY:
				if current_shape == SHAPE.TRIANGLE:
					print("Wrong Shape")
					shape_switch_request.emit(SHAPE.INVALID, true)
				else:
					target_shape = SHAPE.SQUARE if current_shape == SHAPE.CIRCLE else SHAPE.CIRCLE
			CIRCLE_TRIANGLE_SWITCH_KEY:
				if current_shape == SHAPE.SQUARE:
					print("Wrong Shape")
					shape_switch_request.emit(SHAPE.INVALID, true)
				else:
					target_shape = SHAPE.TRIANGLE if current_shape == SHAPE.CIRCLE else SHAPE.CIRCLE
	
	if target_shape != null:
		shape_switch_request.emit(target_shape, false)
		switch_player_shape(target_shape)


func _ready() -> void:
	current_shape = GameState.player_shape
	collision_shape.shape = load(collision_shape_paths[current_shape])
	_heat = GameState.player_heat
	shape_switch_timer.timeout.connect(on_shape_switch_timer_timeout)


func _physics_process(delta: float) -> void:
	move_player(delta)


func switch_player_shape(shape: SHAPE):
	is_movement_allowed = false
	if shape == current_shape:
		return
	next_shape = shape
	
	if current_shape == SHAPE.CIRCLE:
		if shape == SHAPE.SQUARE:
			player_animated_sprite.play("circle_to_square")
		elif shape == SHAPE.TRIANGLE:
			player_animated_sprite.play("circle_to_triangle")
	elif current_shape == SHAPE.SQUARE:
		if shape == SHAPE.CIRCLE:
			player_animated_sprite.play_backwards("circle_to_square")
		#elif shape == SHAPE.TRIANGLE:
			#player_animated_sprite.play_backwards("triangle_to_square")
	elif current_shape == SHAPE.TRIANGLE:
		if shape == SHAPE.CIRCLE:
			player_animated_sprite.play_backwards("circle_to_triangle")
		#elif shape == SHAPE.SQUARE:
			#player_animated_sprite.play("triangle_to_square")
	shape_switch_timer.start()
	current_shape = shape


func on_shape_switch_timer_timeout() -> void:
	match current_shape:
		SHAPE.CIRCLE:
			player_animated_sprite.play("circle")
			collision_shape.position.y = 0
		SHAPE.SQUARE:
			player_animated_sprite.play("square")
			collision_shape.position.y = 0
		SHAPE.TRIANGLE:
			player_animated_sprite.play("triangle")
			collision_shape.position.y = 5
	collision_shape.shape = load(collision_shape_paths[current_shape])
	is_movement_allowed = true


func move_player(delta: float) -> void:
	if !is_movement_allowed:
		return

	var player_attributes: PlayerShape = shape_properties[current_shape]
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = player_attributes.jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction\
	 #and not (is_on_wall() and direction == wall_direction)\
	:
		player_animated_sprite.rotation = direction * 30
		collision_shape.rotation = direction * 30
		velocity.x = direction * player_attributes.speed
	else:
		player_animated_sprite.rotation = 0
		collision_shape.rotation = 0
		velocity.x = move_toward(velocity.x, 0, player_attributes.speed)

	move_and_slide()
	wall_jump()


func use_heat(used_heat: float) -> float:
	_heat -= used_heat
	return _heat


func heat() -> float:
	return _heat


func wall_jump() -> void:
	var is_collider_left: bool = false

	if is_on_wall() and shape_properties[current_shape].can_wall_jump:
		var collision = get_slide_collision(0)
		var collided_body = collision.get_collider()
		if collided_body is TileMapLayer:
			var collider_collision_layer: int = collided_body.tile_set.get_physics_layer_collision_layer(0)
			var is_wall_jumpable: bool = (collider_collision_layer & (1<<(JUMP_WALL_LAYER-1))) or collided_body.is_in_group("jump_wall")
			#wall_jump_timer = collided_body.get_node("WallJumpTimer")
			if collision.get_position().x < position.x:
				is_collider_left = true
		
			if is_wall_jumpable:
				wall_jump_timer_start = Time.get_unix_time_from_system()
				can_wall_jump = true

	if can_wall_jump and Time.get_unix_time_from_system() - wall_jump_timer_start >= 1 or is_on_floor():
		can_wall_jump = false

	if Input.is_action_just_pressed("jump"):
		if can_wall_jump and Time.get_unix_time_from_system() - wall_jump_timer_start <= 1:
			can_wall_jump = false
			velocity.y = WALL_JUMP_VELOCITY
			var pushback_direction: int = 1 if is_collider_left else -1
			#wall_direction = -1*pushback_direction
			velocity.x = pushback_direction * WALL_JUMP_KNOCKBACK
		else:
			can_wall_jump = false
