extends AnimatedSprite2D

@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D

var player: Player

const HEAT_REACHARGE: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(on_area_body_entered)
	area.body_exited.connect(on_area_body_exited)
	timer.start()

func _process(delta: float) -> void:
	if player and timer.is_stopped() and player.heat() < player.MAX_PLAYER_HEAT:
		player.use_heat(min(-HEAT_REACHARGE, player.MAX_PLAYER_HEAT-player.heat()))
		timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_area_body_entered(body: Node2D) -> void:
	print("ENTERED")
	if body.is_in_group("player"):
		player = body

func on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
