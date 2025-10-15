extends Node2D

@onready var platformsParent: Node2D = $Platforms
@onready var timer: Timer = $Timer

var platforms: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	platforms = platformsParent.get_children()
	for idx in range(1, platforms.size(), 2):
		var platform: Platform = platforms[idx]
		platform.update_visibility(false)
	timer.timeout.connect(on_timer_timeout)
	timer.start()

func on_timer_timeout():
	for platform: Platform in platforms:
		platform.update_visibility(!platform.visible)
	timer.start()
