extends Area2D

#signal enemy_freed(enemy: EnemyInfo)

var isAlive = true
var currentPlayerPosition: Vector2;
var enemyObj: EnemyInfo;
var randVelocity: float = randf_range(0.01, 0.05)
var camera_position_y = 0.0

func _ready():
	$Lifespan.start()
	$"../player_camera".connect("GetCameraPosition", self._on_player_camera_camera_move)
	$"..".connect("on_enemy_registered", self._on_level_1_alpha_test_on_enemy_registered)

func _process(_delta):
	#print(self.camera_position_y)
	position.y += 0.01 #randVelocity
	$Label.text = str(position.y).substr(0, 4)
	
	
	#print(self.global_position.y, self.camera_position_y)
	if self.global_position.y > (self.camera_position_y + 110):
		_on_lifespan_timeout()
		#_on_lifespan_timeout()

func _on_lifespan_timeout() -> void:
	if enemyObj:
		#emit_signal("enemy_freed", enemyObj)
		queue_free()

func _on_level_1_alpha_test_on_enemy_registered(enemy: EnemyInfo) -> void:
	enemyObj = enemy

func _on_player_camera_camera_move(camera_position_y: float) -> void:
	self.camera_position_y = camera_position_y
