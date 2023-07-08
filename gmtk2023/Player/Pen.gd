extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var target = get_node("../LaserTarget")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	look_at(target.global_position)
