class_name ButtonPlate extends Area2D


@onready var sprite: Sprite2D = $Sprite2D
var is_pressed = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		position.y += 1.0
		is_pressed = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		position.y -= 1.0
		is_pressed = false
