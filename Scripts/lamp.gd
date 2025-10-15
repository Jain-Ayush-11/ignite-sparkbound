extends AnimatedSprite2D

@onready var light: PointLight2D = $PointLight2D
@onready var trigger_area: Area2D = $TriggerArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("off")
	light.energy = 0
	trigger_area.body_entered.connect(_on_trigger_area_body_entered)


func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		light.energy = 1.5
		play("on")
