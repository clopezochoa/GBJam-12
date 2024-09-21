extends Area2D

var currentPlayerPosition: Vector2;
var enemyObj: EnemyInfo;
var randVelocity: float = randf_range(0.01, 0.02)
var camera_position_y = 0.0

func _ready():
	$Lifespan.start()
	$"../player_camera".connect("GetCameraPosition", self._on_player_camera_camera_move)
	$"..".connect("on_enemy_registered", self._on_level_1_alpha_test_on_enemy_registered)

func _process(_delta):

	
	var base_velocity = 1.0
	if self.enemyObj:
		base_velocity = self.enemyObj.base_velocity
		$Label.text = str(self.enemyObj.isAlive)
		if  not self.enemyObj.isAlive:
			base_velocity = 0
		
	position.y += base_velocity * self.randVelocity
	# else:
	# 	print('is not alive')
	
	

func _on_level_1_alpha_test_on_enemy_registered(enemy: EnemyInfo) -> void:
	self.enemyObj = enemy

func _on_player_camera_camera_move(camera_position_y: float) -> void:
	self.camera_position_y = camera_position_y
