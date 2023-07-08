extends Node

signal blocks_switched

var max_food = 0
var max_dish = 0
var current_food = 0
var collected_food = 0
var DEBUG_MODE = true
var WIN_TEXTS = [
	"Congratulations! Fluffy isn't going to starve now :D",
	"About damn time... Buckaroo hasn't eaten in AGES!",
	"FOODFOODFOODFOODFOODFOOD",
	"*cronching sounds commence*"
]

var text_box = ""

var block_switch = true

func _unhandled_input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func get_win_text():
	return WIN_TEXTS[randi() % WIN_TEXTS.size()]

func init_food():
	max_food += 1

func init_dish():
	max_dish += 1

func collect_food():
	current_food += 1


func pour_food():
	collected_food += 1
	if collected_food == max_dish:
		text_box = get_win_text()
		
func switch_blocks():
	block_switch = !block_switch
	emit_signal("blocks_switched")

func restart_game():
	max_food = 0
	current_food = 0
	block_switch = true
	text_box = ""
	
	var _error = get_tree().reload_current_scene()
