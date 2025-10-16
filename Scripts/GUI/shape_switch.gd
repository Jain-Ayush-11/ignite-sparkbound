extends Control

const POSITION_OFFSET: float = 20.0
const SCALE_OFFSET: float = 0.1

@onready var player: Player
@onready var circle: TextureRect = $Circle
@onready var square: TextureRect = $Square
@onready var triangle: TextureRect = $Triangle
@onready var timer: Timer = $Timer
@onready var error_overlay: TextureRect = $ErrorOverlay

var selected_shape_ui: TextureRect = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	error_overlay.visible = false
	player = get_tree().get_first_node_in_group("player")
	player.shape_switch_request.connect(on_player_shape_switch_request)
	timer.timeout.connect(on_timer_timeout)


func on_player_shape_switch_request(shape: Player.SHAPE, is_input_wrong: bool) -> void:
	if is_input_wrong and shape == Player.SHAPE.INVALID:
		vibrate_ui()
		return
	match shape:
		Player.SHAPE.CIRCLE:
			selected_shape_ui = circle
		Player.SHAPE.SQUARE:
			selected_shape_ui = square
		Player.SHAPE.TRIANGLE:
			selected_shape_ui = triangle
	
	if selected_shape_ui:
		selected_shape_ui.position -= Vector2(POSITION_OFFSET, POSITION_OFFSET)
		selected_shape_ui.scale += Vector2(SCALE_OFFSET, SCALE_OFFSET)
		timer.start()

func on_timer_timeout() -> void:
	if selected_shape_ui:
		selected_shape_ui.position += Vector2(POSITION_OFFSET, POSITION_OFFSET)
		selected_shape_ui.scale -= Vector2(SCALE_OFFSET, SCALE_OFFSET)
	selected_shape_ui = null

func vibrate_ui():
	error_overlay.visible = true
	var tween = create_tween()
	var start_pos = position
	
	for i in range(4):
		tween.tween_property(self, "position", Vector2.RIGHT * 8, 0.03).as_relative()
		tween.tween_property(self, "position", Vector2.LEFT * 8, 0.03).as_relative()
	
	tween.tween_property(self, "position", start_pos, 0.03)
	tween.tween_property(error_overlay, "visible", false, 0.1)
