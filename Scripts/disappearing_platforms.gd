extends Node

@onready var timer: Timer = $PlatformTimer
@onready var air_platforms: Node2D = $AirPlatforms
@onready var trigger_button: ButtonPlate = $TriggerButton

var is_platform_timer_started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	air_platforms.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trigger_button.is_pressed and !is_platform_timer_started:
		update_air_platforms(true)
		timer.start()
		is_platform_timer_started = true
	
	if is_platform_timer_started and timer.is_stopped():
		is_platform_timer_started = false
		update_air_platforms(false)

func update_air_platforms(visible: bool) -> void:
	air_platforms.visible = visible
	var platforms = air_platforms.get_children()
	for platform: Platform in platforms:
		if platform is not Platform:
			continue
		platform.update_visibility(visible)
