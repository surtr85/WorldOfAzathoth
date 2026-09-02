class_name LordMaria
extends DreamLordBase
## FINAL BOSS — Maria: Vessel of Azathoth
## Phase 1: Cosmic Nightmare Entity (Azathoth)
## Phase 2: Emotional Core (Maria begs her father to stop)

signal story_dialogue_triggered(text: String)

func _ready() -> void:
	lord_name = "Vessel of Azathoth"
	sin_type = "final"
	max_health = 1200
	phases = 2

func _transition_phase(new_phase: int) -> void:
	super._transition_phase(new_phase)
	if new_phase == 2:
		lord_name = "Maria"
		story_dialogue_triggered.emit("Father... please stop. Don't wake me up into that cold world again...")
