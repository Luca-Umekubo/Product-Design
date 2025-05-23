extends AudioStreamPlayer

var playlist: Array[AudioStream] = []
var shuffled_indices: Array[int] = []
var current_track_index: int = 0
const AUDIO_FOLDER = "res://Audio/"
var is_server: bool = false
var sync_interval: float = 0.5
var last_sync_time: float = 0.0

func _ready():
	is_server = multiplayer.is_server()
	load_tracks()
	if is_server and not playlist.is_empty():
		shuffle_playlist()
		play_next_track()
	finished.connect(_on_track_finished)

func _process(delta):
	if is_server:
		last_sync_time += delta
		if last_sync_time >= sync_interval:
			sync_playback.rpc(shuffled_indices[current_track_index], get_playback_position())
			last_sync_time = 0.0

func load_tracks():
	var dir = DirAccess.open(AUDIO_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".ogg") or file_name.ends_with(".wav") or file_name.ends_with(".mp3"):
				var track = load(AUDIO_FOLDER + file_name) as AudioStream
				if track:
					playlist.append(track)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error: Could not open ", AUDIO_FOLDER)
	if playlist.is_empty():
		print("Warning: No tracks found in ", AUDIO_FOLDER)

func shuffle_playlist():
	shuffled_indices.clear()
	var indices: Array[int] = []
	for i in playlist.size():
		indices.append(i)
	indices.shuffle()
	shuffled_indices = indices
	current_track_index = 0

func play_next_track():
	if playlist.is_empty():
		return
	if current_track_index >= shuffled_indices.size():
		shuffle_playlist()
	if not shuffled_indices.is_empty():
		var track_index = shuffled_indices[current_track_index]
		stream = playlist[track_index]
		play()
		if is_server:
			sync_playback.rpc(track_index, 0.0)

func _on_track_finished():
	if is_server:
		current_track_index += 1
		play_next_track()

@rpc("authority", "call_remote", "reliable")
func sync_playback(track_index: int, playback_position: float):
	if not is_server:
		if track_index != shuffled_indices[current_track_index] or abs(get_playback_position() - playback_position) > 0.5:
			current_track_index = shuffled_indices.find(track_index)
			if current_track_index != -1 and track_index < playlist.size():
				stream = playlist[track_index]
				play(playback_position)
