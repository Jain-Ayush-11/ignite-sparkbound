class_name Platform extends AnimatableBody2D

@onready var collider: CollisionShape2D = $CollisionShape2D

func update_visibility(visibility: bool) -> void:
	visible = visibility
	collider.disabled = !visibility
