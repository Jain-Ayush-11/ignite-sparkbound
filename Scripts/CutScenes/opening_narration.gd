extends RichTextLabel

@export var reveal_speed: float = 0.05
@export var reveal_by_line: bool = false

var full_text: String
var lines: Array
var current_index: int = 0
var is_writing: bool = false

func _ready() -> void:
	full_text = text
	clear()
	lines = full_text.split("\n")
	reveal_next()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_action") and !is_writing:
		reveal_next()

func reveal_next() -> void:
	if current_index >= lines.size():
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.7)
		tween.tween_property(self, "visible", false, 0.7)
		await GameState.load_next_scene()
		return
	
	is_writing = true
	await reveal_next_word(lines[current_index].split(" "), 0)
	is_writing = false
	current_index += 1
	append_text("\n\n")

func reveal_next_word(line: Array[String], current_idx: int) -> void:
	if current_idx >= line.size():
		return
	
	append_text(line[current_idx] + " ")
	
	current_idx += 1
	await get_tree().create_timer(reveal_speed).timeout
	await reveal_next_word(line, current_idx)
