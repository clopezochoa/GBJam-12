extends AnimationPlayer

signal animation_ended()

func _ready() -> void:
	play("fire")
	connect("animation_finished", self._animation_finished)

func _process(delta: float) -> void:
	pass

func _animation_finished(animation_name: String):
	self.animation_ended.emit()
