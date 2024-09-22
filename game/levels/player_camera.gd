extends Camera2D

signal CameraMove(camera_position_y: float)
signal GetCameraPosition(camera_position_y: float)

var farthestPosition: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.GetCameraPosition.emit(self.position.y)




func _on_player_player_update_position(player: PlayerInfo) -> void:
	if player.instance.global_position.y < (farthestPosition + 100):
		farthestPosition = player.instance.global_position.y - 100
		self.position.y = farthestPosition
		#print(farthestPosition)
		self.CameraMove.emit(farthestPosition)
		var score = int(floor(abs(farthestPosition)))
		$"Score".text = str(score)
		Global.update_score_by_move(score)
