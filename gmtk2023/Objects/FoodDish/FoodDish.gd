extends Area2D

onready var audio = $AudioStreamPlayer

var filled = false

func _ready():
	Global.init_dish()

func fill():
	if filled:
		return
	filled = true

	Global.pour_food()
	audio.play(0)
	visible = false

func _on_FoodDish_body_entered(body):
	if body.has_method("is_player"):
		if Global.current_food > 0:
			fill()

func _on_AudioStreamPlayer_finished():
	queue_free()

