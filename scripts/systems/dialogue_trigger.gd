class_name DialogueTrigger
extends Area2D
## Dialogue and lore interaction trigger.

@export var dialogue_id: String = "intro"
@export var speaker_name: String = "Mysterious Voice"
@export_multiline var text_lines: Array[String] = [
	"Welcome to the Cradle of Dreams...",
	"Pride was their downfall, as it will be yours."
]
@export var trigger_once: bool = true

var triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player") or body.name.to_lower().contains("player")) and not (triggered and trigger_once):
		triggered = true
		_start_dialogue()

func _start_dialogue() -> void:
	print("[%s]: %s" % [speaker_name, text_lines[0] if text_lines.size() > 0 else "..."])
