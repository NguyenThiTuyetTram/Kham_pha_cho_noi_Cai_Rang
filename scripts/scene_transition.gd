extends CanvasLayer

const FADE_TIME := 0.5

var _transitioning := false
var _cover: ColorRect

var music_player: AudioStreamPlayer
var bgm_menu: AudioStream
var bgm_game: AudioStream

func _ready() -> void:
	layer = 100
	_cover = ColorRect.new()
	_cover.color = Color(0.01, 0.012, 0.02, 0.0)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_cover)
	
	# Create background music player
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.volume_db = -8.0
	add_child(music_player)
	
	bgm_menu = load("res://bgm_binh_minh.mp3")
	if bgm_menu != null and (bgm_menu.has_method("set_loop") or "loop" in bgm_menu):
		bgm_menu.set("loop", true)
		
	bgm_game = load("res://bgm_song_nuoc.mp3")
	if bgm_game != null and (bgm_game.has_method("set_loop") or "loop" in bgm_game):
		bgm_game.set("loop", true)
		
	# Start playing menu music
	play_music(bgm_menu)


func change_scene(scene_path: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)
	get_tree().change_scene_to_file(scene_path)
	
	if scene_path == "res://scenes/Game.tscn":
		play_music(bgm_game)
	else:
		play_music(bgm_menu)
		
	await get_tree().process_frame
	await _fade_to(0.0)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transitioning = false


func play_music(stream: AudioStream) -> void:
	if music_player == null or stream == null:
		return
	if music_player.stream == stream:
		return
	music_player.stop()
	music_player.stream = stream
	music_player.play()


func _fade_to(target_alpha: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_cover, "color:a", target_alpha, FADE_TIME)
	await tween.finished


func play_success_sfx() -> void:
	var sample_rate := 22050
	var duration := 0.35
	var num_samples := int(sample_rate * duration)
	var pcm_data := PackedByteArray()
	pcm_data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var freq := 523.25 # C5
		if t > 0.08:
			freq = 659.25 # E5
		
		var sample := sin(2.0 * PI * freq * t)
		var envelope := 1.0 - (t / duration)
		var val := int(sample * envelope * 0.25 * 32767.0)
		pcm_data.encode_s16(i * 2, clamp(val, -32768, 32767))
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = pcm_data
	
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -6.0
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func play_load_sfx() -> void:
	var sample_rate := 22050
	var duration := 0.30
	var num_samples := int(sample_rate * duration)
	var pcm_data := PackedByteArray()
	pcm_data.resize(num_samples * 2)
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var freq := 120.0 + t * 60.0
		var sample := sin(2.0 * PI * freq * t)
		var noise := randf() * 0.3
		var envelope := 1.0 - (t / duration)
		var val := int((sample * 0.6 + noise) * envelope * 0.22 * 32767.0)
		pcm_data.encode_s16(i * 2, clamp(val, -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = pcm_data
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -5.0
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func play_unload_sfx() -> void:
	var sample_rate := 22050
	var duration := 0.28
	var num_samples := int(sample_rate * duration)
	var pcm_data := PackedByteArray()
	pcm_data.resize(num_samples * 2)
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var freq := 320.0 - t * 450.0
		var sample := sin(2.0 * PI * freq * t)
		var envelope := 1.0 - (t / duration)
		var val := int(sample * envelope * 0.18 * 32767.0)
		pcm_data.encode_s16(i * 2, clamp(val, -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = pcm_data
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -6.0
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func play_fail_sfx() -> void:
	var sample_rate := 22050
	var duration := 0.25
	var num_samples := int(sample_rate * duration)
	var pcm_data := PackedByteArray()
	pcm_data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var freq := 150.0
		if t > 0.08 and t < 0.12:
			freq = 0.0 # gap
		elif t >= 0.12:
			freq = 130.0
			
		var sample := sin(2.0 * PI * freq * t)
		if sample > 0.2: 
			sample = 0.5
		elif sample < -0.2: 
			sample = -0.5
		
		var envelope := 1.0 - (t / duration)
		var val := int(sample * envelope * 0.20 * 32767.0)
		pcm_data.encode_s16(i * 2, clamp(val, -32768, 32767))
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = pcm_data
	
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -6.0
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
