extends CanvasLayer

onready var transition = $Transition

func _ready():
	transition.open(1.0,0.25)
	

func _on_Play_button_down():
	transition.close(1.0)
	$Load.start(1.0)

func _on_Load_timeout():
	Global.max_dish = 0
	Global.max_food = 0
	Global.current_food = 0
	Global.collected_food = 0
	Global.block_switch = true
	var _error = get_tree().change_scene("res://World/Viewports.tscn")
