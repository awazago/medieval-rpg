# res://shared/audio_manager.gd
# Gerenciador Global de Áudio, Trilha Sonora Adaptativa e Efeitos Sonoros (SFX)
extends Node

var MUSIC_TRACKS: Dictionary = {}
var SFX_STREAMS: Dictionary = {}

var current_music_track: String = ""
var music_player_a: AudioStreamPlayer
var music_player_b: AudioStreamPlayer
var active_music_player: AudioStreamPlayer

var sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_audio_streams()
	
	# Inicializa reprodutores de música para crossfade suave
	music_player_a = AudioStreamPlayer.new()
	music_player_b = AudioStreamPlayer.new()
	add_child(music_player_a)
	add_child(music_player_b)
	active_music_player = music_player_a
	
	# Inicializa pool de efeitos sonoros
	for i in range(SFX_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_pool.append(p)
		
	# Inicia a trilha padrão serena da Ilha
	play_music("village", 1.0)
	print("[AudioManager] Sistema de áudio e trilha sonora inicializado.")

## Toca uma trilha musical com transição suave (Crossfade)
func play_music(track_key: String, fade_sec: float = 1.2) -> void:
	if current_music_track == track_key:
		return
	if not MUSIC_TRACKS.has(track_key):
		push_warning("[AudioManager] Trilha musical não encontrada: " + track_key)
		return
		
	current_music_track = track_key
	var stream = MUSIC_TRACKS[track_key]
	
	# Alterna reprodutor para o crossfade
	var next_player = music_player_b if active_music_player == music_player_a else music_player_a
	next_player.stream = stream
	next_player.volume_db = -40.0
	next_player.play()
	
	var tween = create_tween().set_parallel(true)
	# Fade in na nova música
	tween.tween_property(next_player, "volume_db", -6.0, fade_sec)
	# Fade out na música anterior
	tween.tween_property(active_music_player, "volume_db", -40.0, fade_sec)
	tween.finished.connect(func(): active_music_player.stop())
	
	active_music_player = next_player
	print("[AudioManager] Transição de música: " + track_key)

## Dispara um efeito sonoro (SFX) usando a pool disponível
func play_sfx(sfx_key: String, volume_offset_db: float = 0.0) -> void:
	if not SFX_STREAMS.has(sfx_key):
		return
		
	var stream = SFX_STREAMS[sfx_key]
	for player in sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_offset_db
			player.play()
			return
			
	# Se todos estiverem ocupados, utiliza o primeiro
	sfx_pool[0].stream = stream
	sfx_pool[0].volume_db = volume_offset_db
	sfx_pool[0].play()

func _init_audio_streams() -> void:
	var music_files = {
		"village": "res://audio/music/dawn_isle_village.wav",
		"crypt": "res://audio/music/ancient_crypt.wav",
		"boss": "res://audio/music/boss_valthor_battle.wav"
	}
	for k in music_files:
		var path = music_files[k]
		if ResourceLoader.exists(path):
			MUSIC_TRACKS[k] = load(path)
			
	var sfx_files = {
		"soulshot_activate": "res://audio/sfx/soulshot_activate.wav",
		"soulshot_hit": "res://audio/sfx/soulshot_hit.wav",
		"level_up": "res://audio/sfx/level_up.wav",
		"sword_swing": "res://audio/sfx/sword_swing.wav",
		"magic_cast": "res://audio/sfx/magic_cast.wav",
		"coins_pickup": "res://audio/sfx/coins_pickup.wav"
	}
	for k in sfx_files:
		var path = sfx_files[k]
		if ResourceLoader.exists(path):
			SFX_STREAMS[k] = load(path)

