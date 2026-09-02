extends Node
## Audio manager supporting crossfading music and positional SFX.

var player_a: AudioStreamPlayer
var player_b: AudioStreamPlayer
var active_player: AudioStreamPlayer

func _ready() -> void:
	player_a = AudioStreamPlayer.new()
	player_b = AudioStreamPlayer.new()
	player_a.bus = "Music"
	player_b.bus = "Music"
	add_child(player_a)
	add_child(player_b)
	active_player = player_a

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
	if not stream:
		return
	var next_player := player_b if active_player == player_a else player_a
	next_player.stream = stream
	next_player.volume_db = -80.0
	next_player.play()
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(active_player, "volume_db", -80.0, fade_time)
	tween.tween_property(next_player, "volume_db", 0.0, fade_time)
	
	await tween.finished
	active_player.stop()
	active_player = next_player

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)

func stop_music(fade_time: float = 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(active_player, "volume_db", -80.0, fade_time)
	await tween.finished
	active_player.stop()
