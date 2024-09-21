extends AnimationPlayer

var anim_player: AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.anim_player = $"." as AnimationPlayer  # Reference your AnimationPlayer node
	self.anim_player.play("alive")
	 # Ensure the animation loops


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.anim_player.is_playing():
		self.anim_player.play()
