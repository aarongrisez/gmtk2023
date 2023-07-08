extends Area2D

onready var audio = $AudioStreamPlayer

var collected = false

func _ready():
	Global.init_food()

func collect():
	if collected:
		return
	collected = true
	
	if Global.max_food != 1:
		audio.pitch_scale = (float(Global.current_food) / (Global.max_food - 1)) + 1
	print(audio.pitch_scale)
	Global.collect_food()
	audio.play(0)
	visible = false

func _on_FoodBag_body_entered(body):
	if body.has_method("is_player"):
		collect()

func _on_AudioStreamPlayer_finished():
	queue_free()

