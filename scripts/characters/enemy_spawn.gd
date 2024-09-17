extends Area2D

signal enemy_freed(enemy: Area2D)

var isAlive = true
var currentPlayerPosition: Vector2;

func _ready():
	$Lifespan.start()

func _process(delta):
	position.y += 0.02

func _on_lifespan_timeout() -> void:
	emit_signal("enemy_freed", self)
	queue_free()
