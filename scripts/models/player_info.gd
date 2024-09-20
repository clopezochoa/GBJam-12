extends Object

class_name PlayerInfo

# Properties
var name: String
var id: int
var layer: Global.Layer
var type: Global.Type
var currentPowerup: String
var isAlive: bool
var instance: Area2D

# Constructor
func _init(_name: String, _id: int, _layer: Global.Layer, _type: Global.Type, _currentPowerup: String, _isAlive: bool, _instance: Area2D):
	self.name = _name
	self.id = _id
	self.layer = _layer
	self.type = _type
	self.currentPowerup = _currentPowerup
	self.isAlive = _isAlive
	self.instance = _instance
