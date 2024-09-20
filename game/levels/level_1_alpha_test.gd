extends Node

signal exit_game
signal defeat
signal win
signal on_enemy_registered(enemy: EnemyInfo)

var	score = 0
var meteorite_pool: Array[MeteoriteBlock] = []

@export var win_screen: PackedScene
@export var enemy_scene: PackedScene

var enemies: EnemyControl = EnemyControl.new()
var cumulative: int = 0

func _ready() -> void:
	Global.isDeafeated = false
	
	process_mode = Node.PROCESS_MODE_PAUSABLE
	get_node("Pause Screen").position.y -= 30
	get_node("Pause Screen").hide()
	get_node("Pause Screen/Resume Button").pressed.connect(self.on_resume_button_pressed)
	get_node("Pause Screen/Exit Button").pressed.connect(self.on_exit_button_pressed)
	
	$Player.connect("defeated", self._on_defeat)
	$Player.connect("player_update_position", self._on_player_move)
	$Player.connect("on_meteor_deleted", self._on_meteor_deleted)

	#$Enemy.connect("enemy_freed", self._on_enemy_freed)	

	#$Areas/Threshhold_1_easy.connect("area_entered",self._on_player_reach_difficlty_area_1)
	#$Areas/Threshhold_2_medium.connect("area_entered",self._on_player_reach_difficlty_area_2)
	#$Areas/Threshhold_3_hard.connect("area_entered",self._on_player_reach_difficlty_area_3)
	#$Areas/Threshhold_4_very_hard.connect("area_entered",self._on_player_reach_difficlty_area_4)
	#$Areas/Shelter.connect("area_entered",self._on_player_win)
	$Player.position.x = 0
	
	#var projectile_node = $Player/projectile_spawner
	#projectile_node.position.x = 0
	#projectile_node.position.y = 0
	#projectile_node.connect("projectile_spawned", self._on_projectile_spawner_projectile_spawned)
	#
	#var power_ups_spawner = $power_ups_spawner
	#power_ups_spawner.connect("power_up_spawn", self._on_power_up_spawn)
	
	var current_level_score_block = Global.score.get_level_block(Global.Level.LEVEL_1)
	Global.score.set_current_level(current_level_score_block)
	Global.emit_current_score()
	Global.emit_level_score(Global.Level.LEVEL_1)
	
	score = 0
	#$Player.start($StartPosition.position)
	$StartTimer.start()
	
	#var player = $Player  # Adjust this path to the actual player node
	#if player:
		#player.player_update_position.connect(_on_player_update_position)
	
	
func _process(_delta: float) -> void:
	enemies.wipe_unseen($player_camera.global_position.y + 120)
	print(len(enemies.enemies))
	
	if $"Pause Timer".is_stopped() == true:
		if Input.is_action_pressed("pause"):
			print("P pressed during unpaused")
			on_pause_button_pressed()
	
	#Pause screen follows player to that it's always in the screen when the player pauses
	#80 is the offset so that it stays in the center (half of 160, the screen size)
	if(is_instance_valid(get_node("Pause Screen"))):
		get_node("Pause Screen").position.x = get_node("Player").position.x - 30

func _physics_process(delta: float) -> void:
	if Global.isDeafeated:
		$env_01_ambient.stop()

func _on_projectile_spawner_projectile_spawned(pos, init_speed, gravity_scale) -> void:
	var meteor_instance: RigidBody2D =  $Player/projectile_spawner.projectile.instantiate() as RigidBody2D
	add_child(meteor_instance)
	meteor_instance.global_position.x = pos
	meteorite_pool.append(MeteoriteBlock.new(meteor_instance, pos))
	meteor_instance.linear_velocity = init_speed * Vector2(0,1)
	meteor_instance.gravity_scale = gravity_scale
	meteor_instance.connect("on_meteor_deleted", self._on_meteor_deleted)
	
func _on_power_up_spawn(power_up_index,power_up_pos_x)->void:
	var power_up_instance: Area2D = $power_ups_spawner.power_ups_pks[power_up_index].instantiate()
	add_child(power_up_instance)
	power_up_instance.connect("deleted",$power_ups_spawner._on_power_up_deleted)
	if(power_up_instance.has_signal("picked_up_magnification")):
		power_up_instance.connect("picked_up_magnification",$Player._on_picked_up_magnification)
	elif(power_up_instance.has_signal("picked_up_miniaturization")):
		power_up_instance.connect("picked_up_miniaturization",$Player._on_picked_up_miniaturization)
	elif(power_up_instance.has_signal("picked_up_shield")):
		power_up_instance.connect("picked_up_shield",$Player._on_picked_up_shield)
	power_up_instance.global_position = Vector2(power_up_pos_x,$power_ups_spawner.global_position.y)

func on_pause_button_pressed() -> void:
	if not Global.isDeafeated:
		get_tree().paused = true
		$Player/player_camera/score.hide()
		$"Pause Screen".show()
		$"Pause Screen".play_pause_audio()
		$"Pause Screen/PauseTimer".start()
		$"Pause Screen/Resume Button".grab_focus()
	
func on_resume_button_pressed() -> void:
	$Player/player_camera/score.show()	
	$"Pause Screen".hide()
	get_tree().paused = false

func on_exit_button_pressed() -> void:
	print("Pressed exit button")
	Global.score.set_current(0)
	Global.reset_current_level_score()
	get_tree().paused = false
	emit_signal("exit_game")

func _on_pause_screen_unpause() -> void:
	print("unpaused by pressing pause button")
	$Player/player_camera/score.show()		
	$"Pause Screen".play_resume_audio()
	$"Pause Timer".start()
	
func _on_defeat() -> void:
	Global.score.set_score_by_level(Global.Level.LEVEL_1, true)
	Global.score.set_current(0)
	emit_signal("defeat")
	
func _on_player_move(_position) -> void:
	#Global.update_score_by_move(_position.x)
	#$Player/player_camera/direction_distance.update_distance(str(int($Areas/Shelter.global_position.x - $Player.global_position.x)))
	var right_offset:int =  130 + 40
	var left_offset:int = 30 + 10
	var to_delete: Array[MeteoriteBlock] = []
	var to_preserve: Array[MeteoriteBlock] = []
	for met in meteorite_pool:
		if (met.offset > _position.x + right_offset) or (met.offset < _position.x - left_offset):
			to_delete.push_back(met)
		else:
			to_preserve.push_back(met)
	for met in to_delete:
		if is_instance_valid(met.meteorite):
			met.meteorite.queue_free()
	meteorite_pool = to_preserve
		
func _on_meteor_deleted(meteor):
	if is_instance_valid(meteor):
		meteor.queue_free()
		var to_preserve: Array[MeteoriteBlock] = []
		for meteorite_block in meteorite_pool:
			if meteorite_block.meteorite != meteor:
				to_preserve.push_back(meteorite_block)
		meteorite_pool = to_preserve

func _on_player_reach_difficlty_area_1(area: Area2D)->void:
	if(area.is_in_group("Player")):
		$Player/projectile_spawner.set_difficulty_level(1);

func _on_player_reach_difficlty_area_2(area: Area2D)->void:
	if(area.is_in_group("Player")):
		$Player/projectile_spawner.set_difficulty_level(2);

func _on_player_reach_difficlty_area_3(area: Area2D)->void:
	if(area.is_in_group("Player")):
		$Player/projectile_spawner.set_difficulty_level(3);

func _on_player_reach_difficlty_area_4(area: Area2D)->void:
	if(area.is_in_group("Player")):
		$Player/projectile_spawner.set_difficulty_level(4);

func _on_player_win(area: Area2D)->void:
	$"Pause Screen".set_process(false)
	await Global.fade(true)
	$Areas/Shelter/win_screen.set_score(Global.score.current_score)
	$Areas/Shelter/win_screen.show()
	await $Areas/Shelter/win_screen.exit
	Global.reset_current_level_score()
	emit_signal("win")

class MeteoriteBlock:
	var meteorite: RigidBody2D
	var offset: int
	func _init(_meteorite: RigidBody2D, _offset: int):
		self.meteorite = _meteorite
		self.offset = _offset

func _on_sort_by_height(a,b):
	if a.global_position.y >= b.global_position.y:
		return a
	else:
		return b

func _on_mob_timer_timeout() -> void:
	self.cumulative += 1
	
		# Create a new instance of the Mob scene.
	var enemy = enemy_scene.instantiate()
	var enemyObj = enemies.add_enemyFromArea2D(self.cumulative, enemy)
	#self.on_enemy_registered.emit(enemyObj)
	#enemies.add_enemies([mob])
	#print(enemies.enemies)
	var enemy_spawn_location = $player_camera/MobPath/MobSpawnLocation
	enemy_spawn_location.progress_ratio = randf()
	enemy.position = Vector2(enemy_spawn_location.position.x, enemy_spawn_location.position.y + $player_camera.position.y +(144/4))

	# Set the mob's direction perpendicular to the path direction.
	#var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.

	# Add some randomness to the direction.
	#direction += randf_range(-PI / 4, PI / 4)
	#mob.rotation = direction

	# Choose the velocity for the mob.
	#var velocity = Vector2(randf_range(150.0, 250.0), 0.0)

	# Spawn the mob by adding it to the Main scene.
	add_child(enemy)
	
	#enemyList.sort_custom(_on_sort_by_height)
	#var enemyToConnect = enemies.get_enemy_by_id(self.cumulative).instance
	#if enemyToConnect:
		#enemyToConnect.connect("enemy_freed", self._on_enemy_freed)

func _on_score_timer_timeout() -> void:
	score += 1

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

#func _on_enemy_freed(enemy: EnemyInfo) -> void:
	#print(len(enemies.enemies))
	#enemies.delete_enemies([enemy])
	##enemy.instance.queue_free()
	#print(len(enemies.enemies))
	##enemyList.erase(enemy)
	#

#func _on_player_update_position(player: PlayerInfo) -> void:
	#print(player.name + " moved")



func _on_player_player_shoot(players: Array[PlayerInfo]) -> void:
	for player in players:
		var closestEnemy: EnemyInfo = null
		#var closestEnemyDiff: int = -1
		for enemy in enemies.enemies:
			#print(enemy.instance.global_position.y)
			#print(player.instance.position.y)
			#print(enemy.instance.global_position.y, player.instance.position.y)
			#if abs(enemy.instance.global_position.y - $player_camera.global_position.y) < 35 and (enemy.instance.global_position.y - 100) > $player_camera.global_position.y:
			
			if enemy.instance.global_position.y > player.instance.global_position.y:
				continue
			#var diff = abs(enemy.global_position.x - position.x) + abs(enemy.global_position.y - position.y)
			if enemy.instance.global_position.x > player.instance.position.x - 15 and enemy.instance.global_position.x < player.instance.position.x + 15:
				closestEnemy = enemy
				break
				
			#if (closestEnemy == null) or (diff < closestEnemyDiff):
			#if (closestEnemy == null):
				#closestEnemy = enemy
				#closestEnemyDiff = diff
				
		if closestEnemy != null:
			var enemy_sprite = closestEnemy.instance.get_node("EnemySprite")  # Get the Sprite2D node
			if enemy_sprite and enemy_sprite is Sprite2D:
				enemy_sprite.modulate = Color(0, 1, 0)  # Green color (R=0, G=1, B=0)
			
			#closestEnemy.queue_free()
			var closestEnemyTimer: Timer = closestEnemy.instance.get_node('Death')
			closestEnemyTimer.connect("timeout", Callable(self, "_kill").bind(closestEnemy))
			closestEnemyTimer.start()
			
					
			
		

func _kill(enemy_to_kill: EnemyInfo):
	enemies.delete_enemies([enemy_to_kill])
	
