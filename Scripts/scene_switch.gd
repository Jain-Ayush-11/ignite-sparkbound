extends Area2D

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.player_heat = player.heat()
		GameState.load_next_scene()
