extends Sprite

var MIN_ROTATION = -1.5777
var MAX_ROTATION = 1.8888
var speed = 250
export var turning = 4.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	var new_rotation = 0
	var current_rotation = get_rotation()
	if Input.is_action_pressed('ui_left'):
		if current_rotation < MAX_ROTATION:
			rotation += turning * delta
	if Input.is_action_pressed('ui_right'):
		if current_rotation > MIN_ROTATION:
			rotation -= turning * delta

	rotate(new_rotation)
