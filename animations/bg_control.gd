extends AnimationPlayer

var isPlaying: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	$".".play("bg")
	#$".".connect("animation_finished", self._on_animation_ended)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _on_animation_ended(_message):
	#$".".play("bg")

func _on_player_player_update_position(player: PlayerInfo) -> void:
	if not self.isPlaying:
		$".".play("bg")
		self.isPlaying = true
		
func _on_player_player_stopped() -> void:
	if self.isPlaying:
		$".".pause ()
		self.isPlaying = false
