extends Node

@onready var heat_move_platform: ButtonMovingPlatform = $HeatMovePlatform
@onready var bring_back_button_left: ButtonPlate = $BringBackButtonLeft
@onready var bring_back_button_right: ButtonPlate = $BringBackButtonRight

var platform_animation_player: AnimationPlayer

func _ready() -> void:
	platform_animation_player = heat_move_platform.get_node_or_null("AnimationPlayer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (bring_back_button_left.is_pressed or bring_back_button_right.is_pressed):
		move_platform()
	
func move_platform() -> void:
	if bring_back_button_left.is_pressed and platform_animation_player.current_animation_position > 0:
		if platform_animation_player.current_animation_position == platform_animation_player.current_animation_length:
			platform_animation_player.seek(platform_animation_player.current_animation_length - 0.001)
		heat_move_platform.move_platform(platform_animation_player, heat_move_platform.PLATFORM_DIRECTION.LEFT, 2.5)
	elif bring_back_button_right.is_pressed and platform_animation_player.current_animation_position < platform_animation_player.current_animation_length:
		if platform_animation_player.current_animation_position == 0:
			platform_animation_player.seek(0.001)
		heat_move_platform.move_platform(platform_animation_player, heat_move_platform.PLATFORM_DIRECTION.RIGHT, 2.5)
		
