extends Node

# AudioManager singleton for playing sound effects and ambient audio

var sfx_streams: Dictionary = {}
var music_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 12

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_all_sounds()
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = -12.0
	add_child(music_player)
	
	# Create SFX pool
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_pool.append(p)
		
	play_ambient()

func load_all_sounds() -> void:
	var sound_names = [
		"slash", "hit_enemy", "hit_player", "dash",
		"coin", "potion", "pot_break", "chest_open",
		"level_up", "spell_cast", "boss_roar", "ambient_drone"
	]
	for s_name in sound_names:
		var path = "res://assets/audio/" + s_name + ".wav"
		if ResourceLoader.exists(path):
			var res = load(path)
			if res:
				sfx_streams[s_name] = res

func play_sfx(sound_name: String, pitch_range: float = 0.1, volume_db: float = 0.0) -> void:
	if not sfx_streams.has(sound_name):
		return
	
	# Find idle player in pool
	for p in sfx_pool:
		if not p.playing:
			p.stream = sfx_streams[sound_name]
			p.volume_db = volume_db
			if pitch_range > 0.0:
				p.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
			else:
				p.pitch_scale = 1.0
			p.play()
			return
			
	# If pool full, reuse first
	var p = sfx_pool[0]
	p.stream = sfx_streams[sound_name]
	p.volume_db = volume_db
	p.pitch_scale = 1.0
	p.play()

func play_ambient() -> void:
	if sfx_streams.has("ambient_drone"):
		music_player.stream = sfx_streams["ambient_drone"]
		music_player.play()
		# When finished, loop it
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	if music_player and music_player.stream:
		music_player.play()
