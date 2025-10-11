extends CharacterBody2D

enum SHAPE {CIRCLE, SQUARE, TRIANGLE}

var current_shape = null
var next_shape = null

class PlayerShape:
	var weight: int
	var speed: int
	var jump_velocity: int

	func _init(weight: int, speed: int, jump_velocity: int) -> void:
		self.weight = weight
		self.speed = speed
		self.jump_velocity = jump_velocity


var circle = PlayerShape.new(50, 250, -350)
var square = PlayerShape.new(100, 50, -100)
var triangle = PlayerShape.new(5, 300, -400)

var shape_properties = {
	SHAPE.CIRCLE: circle,
	SHAPE.SQUARE: square,
	SHAPE.TRIANGLE: triangle
}

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
	if direction:
		velocity.x = direction * player_attributes.speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_attributes.speed)

	move_and_slide()
