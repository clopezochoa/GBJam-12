extends Object

class_name PlayerControl

var players: Array[PlayerInfo]
var current_player: PlayerInfo

var shoot_cooldowns: Array[Timer] = []

func _init(players: Array[PlayerInfo] = []):
	if len(players) != 0:
		for player in players:
			self.players.push_back(player)

func add_players(players_to_add: Array[PlayerInfo]):
	self.players.append_array(players_to_add)
			
func get_available_shooters():
	var result: Array[PlayerInfo] = []
	for player in players:
		if not player.timer.time_left:
			result.push_back(player)
	return result

func delete_players(players_to_delete: Array[PlayerInfo]):
	var tmp: Array[PlayerInfo] = []
	for _player in self.players:
		if not players_to_delete.has(_player):
			tmp.push_back(_player)
	self.players = tmp
	
func get_player_by_name(name: String) -> PlayerInfo:
	var result: PlayerInfo = null
	for player in self.players:
		if player.name == name:
			result = player
			break
	return result
	
func get_player_by_id(id: int) -> PlayerInfo:
	var result: PlayerInfo = null
	for player in self.players:
		if player.id == id:
			result = player
			break
	return result
	
func set_current(player: PlayerInfo):
	self.current_player = player
	
func get_current() -> PlayerInfo:
	return self.current_player
