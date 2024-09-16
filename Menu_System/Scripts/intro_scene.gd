extends Node2D
signal intro_ended()

# Called when the node enters the scene tree for the first time.
func _ready():
	var music = $Loop1
	var anim = $intro_scene_animation
	music.play()
	anim.play("intro")
	anim.connect("animation_finished", self._on_intro_scene_ended)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_anything_pressed():
		emit_signal("intro_ended")

func _on_intro_scene_ended(_message):
	emit_signal("intro_ended")
