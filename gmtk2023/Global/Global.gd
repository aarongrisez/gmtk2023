extends Node

signal blocks_switched

var inc = 0
func print_once(string):
	if inc == 0:
		print(string)
		
func print_every(nframes, string):
	if inc % nframes == 0:
		print(string)

func print_val(name, val):
	print("{name}: {val}".format({"name": name, "val": val}))

func print_val_once(name, val):
	if inc == 0:
		print_val(name, val)

func print_val_every(nframes, name, val):
	if inc % nframes == 0:
		print_val(name, val)

func _physics_process(_delta):
	inc += 1


var max_food = 0
var max_dish = 0
var current_food = 0
var collected_food = 0
var DEBUG_MODE = true
var WIN_TEXTS = [
	"Congratulations! Fluffy isn't going to starve now :D",
	"About time... Dr. Bojangles hasn't eaten in AGES!",
	"FOODFOODFOODFOODFOODFOOD",
	"c r o n c h i n g",
	"c r o n c h i n g  INTENSIFIES",
	"Milo needs to replenish all the calories spent sleeping.",
	"The first kibble hadn't even hit the bowl before Oliver came running",
	"How does Oreo know when it's an hour before my alarm is set to wake me up?",
	"A CRASH and furious scampering noises immediately follow the sound of kibble on porcelain."
]
var SCENES = [
	"res://World/World1.tscn",
	"res://World/World2.tscn",
	"res://World/World3.tscn",
	"res://World/World4.tscn",
	"res://World/World5.tscn",
	"res://World/World5a.tscn",
	"res://World/World5b.tscn",
	"res://World/World6.tscn",
	"res://UI/GameOver.tscn"
]

func init_scene_map():
	var scene_map = {"": SCENES[0]}
	for i in range(len(SCENES) - 1):
		scene_map[SCENES[i]] = SCENES[i + 1]
	return scene_map

var scene_map = init_scene_map()

var rng = RandomNumberGenerator.new()

# Initial world (change this to test your world of choice)
var current_world = "res://World/World1.tscn"

func reset_counters():
	max_food = 0
	max_dish = 0
	current_food = 0
	collected_food = 0
	
func get_current_world():
	return current_world

func transition_next_scene():
	reset_counters()
	
	current_world = scene_map[current_world]
	if "World" in current_world:
		if (get_tree().get_current_scene().name != "ViewportController"):
			get_tree().change_scene("res://World/Viewports.tscn")

		get_tree().get_current_scene().set_world(current_world)
	else:
		get_tree().change_scene(current_world)

var currently_notifying = false

var text_box = ""

var block_switch = true

func _unhandled_input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func get_win_text():
	rng.set_seed(hash(String(OS.get_time())))
	return WIN_TEXTS[rng.randi() % WIN_TEXTS.size()]

func init_food():
	max_food += 1

func init_dish():
	max_dish += 1

func collect_food():
	current_food += 1

func pour_food():
	collected_food += 1
	current_food -= 1
		
func switch_blocks():
	block_switch = !block_switch
	emit_signal("blocks_switched")

func restart_game():
	reset_counters()
	block_switch = true
	text_box = ""
	
	var _error = get_tree().reload_current_scene()
