class_name ButtonPlate extends Area2D


@onready var sprite: Sprite2D = $Sprite2D
var is_pressed: bool = false
var _has_player_entered: bool = false
var player: Player

func _physics_process(delta: float) -> void:
	if player:
		if player.shape_properties[player.current_shape].can_transfer_heat and !is_pressed:
			position.y += 1.0
			is_pressed = true
		


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_has_player_entered = true
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if is_pressed:
			position.y -= 1.0
			is_pressed = false
		_has_player_entered = false
		player = null
