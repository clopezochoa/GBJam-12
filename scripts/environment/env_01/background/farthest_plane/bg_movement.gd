extends Sprite2D

signal player_update_position(position)
@export var speed = 100
var active_speed = speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_player_update_position(position: Variant) -> void:
	self.position.y = position.y - 40
