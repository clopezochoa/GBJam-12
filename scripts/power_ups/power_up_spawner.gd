extends Node2D

##If power_up_pos_x == 1000
signal power_up_spawn(power_up_index,power_up_pos_x)

@export_category("Spawner properties")
	
@export var spacing: int = 80
@export_range(0,100) var drop_chance: int = 20
@export var spawner_width: int = 3000
@export var try_spawn_power_up_per_second: int = 2

@export var power_ups_pks: Array[PackedScene]
@export var power_ups: Array[Area2D]
#@export var place_holder: PackedScene
@export var Player: Node2D

var spawners: Array[Marker2D]
var is_marker_available: Array[bool]

var rand: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	for i in spawner_width/spacing:
		spawners.append(Marker2D.new())
		spawners[i].global_position.x = i*spacing
		is_marker_available.append(true)
	#for i in spawners.size():
	#	var instance = place_holder.instantiate() as Sprite2D
	#	add_child(instance)
	#	instance.position = spawners[i].position
	randomize()
	$Timer.wait_time = 1/try_spawn_power_up_per_second
	$Timer.connect("timeout",self._on_try_spawn_power_up)
	
func detect_empty_position(player_pos_x: int)->int:
	var avaiable_position_x: int = -1000
	for i in spawners.size():
		if(is_marker_available[i] == true && player_pos_x+160>spawners[i].global_position.x):
			return spawners[i].global_position.x
	return avaiable_position_x;
	
func _on_try_spawn_power_up()->void:
	var power_up_pos_x: int = 0
	if((rand.randi()%100)>drop_chance):
		return;
	power_up_pos_x = detect_empty_position(Player.global_position.x)
	if(power_up_pos_x == -1000):
		return;
	var power_up_index: int = randi_range(0,2)
	emit_signal("power_up_spawn",power_up_index,power_up_pos_x)
	
	
