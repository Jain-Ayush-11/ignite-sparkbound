extends Control

@onready var start: Button = $VBoxContainer/Start
@onready var quit: Button = $VBoxContainer/Quit

func _ready() -> void:
	start.pressed.connect(on_start_pressed)
	quit.pressed.connect(on_quit_pressed)

func on_start_pressed() -> void:
	GameState.load_next_scene()

func on_quit_pressed() -> void:
	GameState.quit_game()
