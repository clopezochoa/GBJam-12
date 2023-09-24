extends Area2D

signal defeated()
signal player_update_position(position)

@export var dash_offset = 0.1
@export var dash_speed = 400
@export var speed = 100
@export var defeat_tex = preload("res://assets/graphic/characters/hero/sprite_sheets/defeat/character_01_defeat_sheet.png")

var power_up: PowerUp = null
var power_up_stash: PowerUp = null
var counter = 0.0
var delta_deadend = 0
var isDashing = false
var isMortal = true

func _ready():
	$hero_animations.play("idle")
	self.set_defeat_animation(4)

func _process(delta):
	if counter > 1000.0:
		counter = 0.0
	counter += delta
	var active_speed = speed
	var velocity = Vector2.ZERO
	var update_position = false
	var player_run_sfx = $player_sfx as AudioStreamPlayer

	active_speed = _dash_handler()
	active_speed = _power_up_handler()
	
	if not Global.isDeafeated:
		if Input.is_action_pressed("dpad_right"):
			$hero_animations.play("run_right")
			velocity.x += 1
			update_position = true
		elif Input.is_action_pressed("dpad_left"):
			$hero_animations.play("run_left")
			velocity.x -= 1
			update_position = true
		else:
			$hero_animations.play("idle")
			player_run_sfx.stop()
			isDashing = false
			
	velocity = velocity.normalized() * active_speed
	position += velocity * delta
	
	if update_position:
		emit_signal("player_update_position", $".".global_position)
		if not player_run_sfx.playing:
			player_run_sfx.play()



func _on_body_entered(body: Node2D) -> void:
	if not Global.isDeafeated and body.is_in_group("Meteorite"):
		if isMortal:
			Global.isDeafeated = true
			$hero_animations.play("defeat")
			await $hero_animations.animation_finished
			emit_signal("defeated")
		else:
			self.power_up.hits_left -= 1
			

func _dash_handler():
	var _active_speed = speed
	if power_up == null or not power_up.active:
		if isDashing and counter >= delta_deadend:
			_active_speed = speed
			isDashing = false
		elif isDashing and counter < delta_deadend:
			_active_speed = dash_speed
		elif Input.is_action_just_pressed("a") and not isDashing:
			_active_speed = dash_speed
			isDashing = true
			delta_deadend = counter + dash_offset
	return _active_speed

func _power_up_handler():
	var _active_speed = speed	
	if not isDashing and power_up != null:
		if power_up.active:
			if power_up.hasTimer:
				if counter >= power_up.destroy_time:
					_active_speed = speed
					print("power up has gone: " + Global.PowerUpName[power_up.type])
					get_stashed_power_up()
					
				elif counter < power_up.destroy_time:
					_active_speed = speed * power_up.speed_factor
					print("power up is active: " + Global.PowerUpName[power_up.type])
			else:
				if isMortal and power_up.hits_left > 0:
					isMortal = false
					print("power up is active: " + Global.PowerUpName[power_up.type])
				elif power_up.hits_left <= 0:
					isMortal = true
					get_stashed_power_up()
					print("power up has gone: " + Global.PowerUpName[power_up.type])
		elif Input.is_action_just_pressed("b"):
			power_up.activate_power(counter)
			print("power up engaged: " + Global.PowerUpName[power_up.type])
	return _active_speed

func set_defeat_animation(times) -> void:
	var defeat_animation = $hero_animations.get_animation("defeat") as Animation
	defeat_animation.length = float(times * 0.4)
	var track = defeat_animation.add_track(Animation.TYPE_VALUE, 0)
	defeat_animation.track_set_enabled(track, true)
	defeat_animation.track_set_path(track, "hero_mesh:frame")
	for time in range(times):
		for frame in range(4):
			var key = frame + (4 * time)
			var seconds = float(key/10.0) + 0.1
			defeat_animation.track_insert_key(track, seconds, frame)

	var tex_track = defeat_animation.add_track(Animation.TYPE_VALUE, 1)
	defeat_animation.track_set_enabled(tex_track, true)
	defeat_animation.track_set_path(tex_track, "hero_mesh:texture")
	defeat_animation.track_insert_key(tex_track, 0.0, defeat_tex)
	
func _on_picked_up_magnification(speed_mul,scale_mul)->void:
	var _power_up = PowerUp.new(Global.PowerUp.BIG, 5.0)
	set_stashed_power_up(_power_up)
	print("Picked up magnification")
	
func _on_picked_up_miniaturization(speed_mul,scale_mul)->void:
	var _power_up = PowerUp.new(Global.PowerUp.SMALL, 5.0)
	set_stashed_power_up(_power_up)
	print("Picked up miniaturization")
	
func _on_picked_up_shield(shield_time)->void:
	var _power_up = PowerUp.new(Global.PowerUp.SHIELD, 2.0)
	set_stashed_power_up(_power_up)
	print("Picked up shield")

func get_stashed_power_up():
	if self.power_up_stash != null:
		self.power_up = self.power_up_stash
		self.power_up_stash = null
	else:
		self.power_up = null
		
func set_stashed_power_up(_power_up):
	if self.power_up == null:
		self.power_up = _power_up
	else:
		self.power_up_stash = _power_up

class PowerUp:
	var active: bool = false
	var type: Global.PowerUp
	var hasTimer: bool = true
	var destroy_time: float
	var hits_left: int = 0
	var endurance: float = 0
	var speed_factor: float = 1.0
	var scale_factor: float = 1.0
	
	func _init(_type: Global.PowerUp, _charge: float = 1.0):
		self.type = _type
		self.endurance = _charge
		if _type == Global.PowerUp.BIG:
			self.speed_factor = 0.5
			self.scale_factor = 2.25
		elif _type == Global.PowerUp.SMALL:
			self.speed_factor = 2
			self.scale_factor = 0.75
		elif _type == Global.PowerUp.SHIELD:
			self.hasTimer = false
			
	func activate_power(_counter):
		self.active = true
		if self.type == Global.PowerUp.SHIELD:
			self.hits_left = int(self.endurance)
		else:
			self.destroy_time = _counter + endurance
		# PLAY TRANSFORM ANIMATION

