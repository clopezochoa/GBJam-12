extends Node2D

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _on_animation_player_animation_ended() -> void:
	queue_free()
