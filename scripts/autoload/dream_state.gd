extends Node
## Manages surreal physics, dream distortions, and reality glitches.

signal reality_shifted(new_stability: float)
signal anomaly_triggered(anomaly_type: String)
signal dream_deepened(level: int)

var reality_stability: float = 1.0  # 1.0 = baseline, 0.0 = total cosmic nightmare
var dream_distortion_level: int = 0
var active_anomalies: Array[String] = []

func destabilize(amount: float) -> void:
	reality_stability = clamp(reality_stability - amount, 0.0, 1.0)
	reality_shifted.emit(reality_stability)
	if should_trigger_anomaly():
		_roll_anomaly()

func get_distortion_shader_params() -> Dictionary:
	return {
		"chromatic_aberration": (1.0 - reality_stability) * 0.05,
		"wave_amplitude": (1.0 - reality_stability) * 10.0,
		"color_saturation": lerp(1.0, 0.3, 1.0 - reality_stability)
	}

func should_trigger_anomaly() -> bool:
	var chance := (1.0 - reality_stability) * 0.3
	return randf() < chance

func register_anomaly(anomaly_type: String) -> void:
	if not active_anomalies.has(anomaly_type):
		active_anomalies.append(anomaly_type)
		anomaly_triggered.emit(anomaly_type)

func clear_anomalies() -> void:
	active_anomalies.clear()

func _roll_anomaly() -> void:
	var types: Array[String] = ["floating_eye", "gravity_flip", "disappearing_door", "whispering_walls", "shadow_duplicate"]
	var selected: String = types[randi() % types.size()]
	register_anomaly(selected)
