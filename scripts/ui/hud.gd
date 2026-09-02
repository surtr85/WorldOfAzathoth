class_name HUD
extends CanvasLayer
## UI HUD Manager for World of Azathoth.

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar if has_node("MarginContainer/VBoxContainer/HealthBar") else null
@onready var corruption_bar: ProgressBar = $MarginContainer/VBoxContainer/CorruptionBar if has_node("MarginContainer/VBoxContainer/CorruptionBar") else null
@onready var area_label: Label = $MarginContainer/VBoxContainer/AreaLabel if has_node("MarginContainer/VBoxContainer/AreaLabel") else null
@onready var dialogue_box: PanelContainer = $DialogueBox if has_node("DialogueBox") else null
@onready var dialogue_text: Label = $DialogueBox/MarginContainer/Label if has_node("DialogueBox/MarginContainer/Label") else null

func _ready() -> void:
	if GameManager:
		_update_area_name(GameManager.current_area)
	if DreamState:
		DreamState.reality_shifted.connect(_on_reality_shifted)

func update_health(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func _on_reality_shifted(new_stability: float) -> void:
	if corruption_bar:
		corruption_bar.value = (1.0 - new_stability) * 100.0

func _update_area_name(area_id: String) -> void:
	if area_label:
		match area_id:
			"pride_palace": area_label.text = "I — THE GOLDEN PALACE OF PRIDE"
			"greed_vault": area_label.text = "II — THE ENDLESS VAULT OF GREED"
			"lust_garden": area_label.text = "III — THE CRIMSON GARDEN OF LUST"
			"envy_mirror": area_label.text = "IV — THE MIRROR CITY OF ENVY"
			"gluttony_abyss": area_label.text = "V — THE LIVING ABYSS OF GLUTTONY"
			"wrath_battlefield": area_label.text = "VI — THE BURNING BATTLEFIELD OF WRATH"
			"sloth_frozen": area_label.text = "VII — THE FROZEN DREAM OF SLOTH"
			"heart_of_dreams": area_label.text = "THE HEART OF DREAMS"
			_: area_label.text = "AZATHOTH LAND"

func show_dialogue(speaker: String, text: String) -> void:
	if dialogue_box and dialogue_text:
		dialogue_text.text = "%s: \"%s\"" % [speaker, text]
		dialogue_box.visible = true

func hide_dialogue() -> void:
	if dialogue_box:
		dialogue_box.visible = false
