extends Node2D

@onready var lake_1: TileMapLayer = $TileMapLayer
@onready var lake_2: TileMapLayer = $TileMapLayer2
@onready var timer: Timer = $Timer

var switchLakeFlag = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lake_1.visible = true
	lake_2.visible = false
	timer.start()


func _on_timer_timeout() -> void:
	if switchLakeFlag:
		lake_1.visible = false
		lake_2.visible = true
	else:
		lake_1.visible = true
		lake_2.visible = false
	switchLakeFlag = !switchLakeFlag
		
