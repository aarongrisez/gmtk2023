extends Control

var MIN_ZOOM = 0.30
var MAX_ZOOM = 0.50

onready var cat_viewport = $CatViewportContainer/CatViewport
onready var player_viewport = $PlayerViewportContainer/PlayerViewport
onready var cat_camera = $CatViewportContainer/CatViewport/CatCamera
onready var player_camera = $PlayerViewportContainer/PlayerViewport/PlayerCamera
var cat = null
var player = null

var current_world_path = ""

func set_remote_transform(camera, body):
	var remote_transform = RemoteTransform2D.new()
	remote_transform.remote_path = camera.get_path()
	body.add_child(remote_transform)

func set_world(world_scene):
	current_world_path = world_scene

	var current_world = cat_viewport.find_node("World")
	if current_world != null:
		cat_viewport.remove_child(current_world)

	world_scene = load(world_scene).instance()
	cat_viewport.add_child(world_scene)
	world_scene.set_owner(get_tree().get_current_scene())
	player_viewport.world_2d = cat_viewport.world_2d
	
	first_process = true
	
func get_current_world():
	return current_world_path

func _ready():
	set_world("res://World/World6.tscn")
	
var first_process = true

func _process(delta):
	if first_process:
		cat = get_tree().get_current_scene().find_node("Cat").find_node("KinematicBody2D")
		cat_camera = get_tree().get_current_scene().find_node("CatCamera")
		player = get_tree().get_current_scene().find_node("Player")
		player_camera = get_tree().get_current_scene().find_node("PlayerCamera")
		set_remote_transform(cat_camera, cat)
		set_remote_transform(player_camera, player)
		
	first_process = false

	var add_offset = Vector2(-120, -70)		
	var current_zoom = cat_camera.zoom

	if Input.is_action_pressed('ui_down'):
		if current_zoom.x < MAX_ZOOM:
			cat_camera.zoom.x += 0.01
			cat_camera.zoom.y += 0.01

	if Input.is_action_pressed('ui_up'):
		if current_zoom.y > MIN_ZOOM:
			cat_camera.zoom.x -= 0.01
			cat_camera.zoom.y -= 0.01

	cat_camera.offset = Vector2(100, 50) - ((cat_camera.zoom.x / MIN_ZOOM) - 1) * add_offset
