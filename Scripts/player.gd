class_name Player extends CharacterBody2D

class PlayerShape:
	var weight: int
	var speed: int
	var jump_velocity: int

	func _init(weight: int, speed: int, jump_velocity: int) -> void:
		self.weight = weight
		self.speed = speed
		self.jump_velocity = jump_velocity

enum SHAPE {CIRCLE, SQUARE, TRIANGLE}

var current_shape = null
var next_shape = null

var circle = PlayerShape.new(50, 250, -350)
var square = PlayerShape.new(100, 50, -100)
var triangle = PlayerShape.new(5, 300, -400)

var shape_properties = {
	SHAPE.CIRCLE: circle,
	SHAPE.SQUARE: square,
	SHAPE.TRIANGLE: triangle
}

@export var _heat: float

const JUMP_WALL_LAYER: int = 16

const WALL_JUMP_KNOCKBACK: float = 1000
const WALL_JUMP_VELOCITY: float = -400
const WALL_JUMP_TIME_OFFSET: float = 0.1

var can_wall_jump: bool = false
var is_wall_jumping: bool = false
var wall_jump_timer_start: float
var wall_jump_collider_direction: int
#var wall_direction: float

#@onready var direction_sprite: Sprite2D = $DirectionSprite
@onready var player_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _input(event: InputEvent) -> void:
	var target_shape = null
	if event.is_action_pressed("switch_shape"):
		match event.as_text():
			"Q":
				target_shape = SHAPE.SQUARE
			"E":
				target_shape = SHAPE.CIRCLE
	
	if target_shape != null:
		switch_player_shape(target_shape)

func _ready() -> void:
	current_shape = SHAPE.CIRCLE

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	move_player(delta)

func switch_player_shape(shape: SHAPE):
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
		elif shape == SHAPE.TRIANGLE:
			player_animated_sprite.play_backwards("triangle_to_square")
	elif current_shape == SHAPE.TRIANGLE:
		if shape == SHAPE.CIRCLE:
			player_animated_sprite.play_backwards("circle_to_triangle")
		elif shape == SHAPE.SQUARE:
			player_animated_sprite.play("triangle_to_square")
	current_shape = shape

func move_player(delta: float) -> void:
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
		velocity.x = direction * player_attributes.speed
	else:
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

	if is_on_wall():
		var collision = get_slide_collision(0)
		var collided_body = collision.get_collider()
		if collided_body is TileMapLayer:
			var collider_collision_layer: int = collided_body.tile_set.get_physics_layer_collision_layer(0)
			var is_wall_jumpable: bool = collider_collision_layer & (1<<(JUMP_WALL_LAYER-1))
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
