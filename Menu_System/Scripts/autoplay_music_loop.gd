extends AudioStreamPlayer

var current_track = 0
var track_1 = preload("res://assets/audio/music/environment/env_01/ambient/level_1_music_1.wav")
var track_2 = preload("res://assets/audio/music/environment/env_01/ambient/level_1_music_2.wav")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()
	connect("finished", change_track)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_track():
	if self.current_track == 0:
		stream = track_2
	else:
		stream = track_1
	
	play()
