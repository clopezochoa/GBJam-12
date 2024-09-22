extends Control

signal play_pressed()

var score: int = 0

func _ready():
	var music = $Loop1
	music.play()

	var score = Global.get_score()
	#$"main-menu-music".play()
	if score <= 0:
		$"Score".visible = false
	else:
		$"Score/Value".text = str(score)
		$"Score".visible = true
	
	Global.score.set_current(0)


func _process(_delta):
	pass


func _input(event):
	if event.is_action_pressed("start") or event.is_action_pressed("a") or event.is_action_pressed("b"):
		emit_signal("play_pressed")

func _on_play_button_pressed() -> void:
	$UI_click.play()
	await $UI_click.finished
	emit_signal("play_pressed")

#func update_score(_score: String) -> void:
	#print(_score, "Main menu")
	#$"Score/Value".text = _score
	#$"Score".visible = true
