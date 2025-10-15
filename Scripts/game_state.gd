extends Node

var scene_array = [
	"res://Scenes/Levels/level_1.tscn",
	"res://Scenes/Levels/level_2.tscn",
	"res://Scenes/Levels/level_3.tscn"
]

var current_scene_index: int = 0
var player_heat = 50
var player_shape = Player.SHAPE.CIRCLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func load_next_scene() -> void:
	current_scene_index += 1
	if current_scene_index == scene_array.size():
		current_scene_index = 0
	get_tree().change_scene_to_file(scene_array[current_scene_index])
