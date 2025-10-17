extends Area2D

var player_label: RichTextLabel
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var rich_text_label_2: RichTextLabel = $RichTextLabel2

@export var initial_visible: bool = false

func _ready() -> void:
	body_entered.connect(on_self_body_entered)
	body_exited.connect(on_self_body_exited)
	rich_text_label.visible = initial_visible
	rich_text_label_2.visible = initial_visible
	
func on_self_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		rich_text_label.visible = true
		if rich_text_label_2:
			rich_text_label_2.visible = true

func on_self_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		rich_text_label.visible = false
		if rich_text_label_2:
			rich_text_label_2.visible = false
