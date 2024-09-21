extends Object

class_name EnemyInfo

# Properties
#var name: String
var id: int
var layer: Global.Layer
var type: Global.Type
var subtype: Global.EnemyType
#var currentPowerup: String
var health: int
var isAlive: bool
var instance: Area2D
var base_velocity: float

# Constructor
func _init(_id: int, _layer: Global.Layer, _type: Global.Type, _subtype: Global.EnemyType, _isAlive: bool, _instance: Area2D, _base_velocity: float):
	self.id = _id
	self.layer = _layer
	self.type = _type
	self.subtype = _subtype
	self.isAlive = _isAlive
	self.instance = _instance
	self.base_velocity = _base_velocity
