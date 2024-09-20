extends Object

class_name EnemyControl

var enemies: Array[EnemyInfo]
var current_enemy: EnemyInfo

func _init(enemies: Array[EnemyInfo] = []):
	if len(enemies) != 0:
		for enemy in enemies:
			self.enemies.push_back(enemy)

func add_enemies(enemies_to_add: Array[EnemyInfo]):
	self.enemies.append_array(enemies_to_add)
	
func add_enemyFromArea2D(id: int, value: Area2D):
	var new_enemy = EnemyInfo.new(id, Global.Layer.OVER, Global.Type.CHARACTER, Global.EnemyType.SOLDIER, true, value)
	self.enemies.push_back(new_enemy)
	return new_enemy
	
func delete_enemies(enemies_to_delete: Array[EnemyInfo]):
	var tmp: Array[EnemyInfo] = []
	for _enemy in self.enemies:
		if not enemies_to_delete.has(_enemy):
			tmp.push_back(_enemy)
	for enemy in enemies_to_delete:
		enemy.instance.queue_free()
	self.enemies = tmp

func get_enemy_by_id(id: int) -> EnemyInfo:
	var result: EnemyInfo = null
	for enemy in self.enemies:
		if enemy.id == id:
			result = enemy
			break
	return result
	
func set_current(enemy: EnemyInfo):
	self.current_enemy = enemy
	
func get_current() -> EnemyInfo:
	return self.current_enemy

func wipe_unseen(camera_low_limit: float):
	var enemies_to_wipe: Array[EnemyInfo] = []
	for enemy in self.enemies:
		if enemy.instance.global_position.y > camera_low_limit:
			enemies_to_wipe.append(enemy)
	if enemies_to_wipe and len(enemies_to_wipe) > 0:
		self.delete_enemies(enemies_to_wipe)
