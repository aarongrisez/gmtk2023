extends Sprite

var MIN_ROTATION = -0.950007
var MAX_ROTATION = 0.965705
var speed = 250
export var turning = 1.0

var raycast_origin = Vector2(0, 0)
var raycast_collision = Vector2(0, 0)

var movement_dir = Vector2(0, 0)
var movement_speed = 200
var movement_velocity = Vector2(0, 0)

onready var raycast = get_tree().get_current_scene().find_node("RayCast2D")
onready var destination = get_tree().get_current_scene().find_node("Destination")
onready var catKinematicBody = get_tree().get_current_scene().find_node("Cat").find_node("KinematicBody2D")

func _ready():
	pass # Replace with function body.
	
func _draw():
	if Input.is_action_pressed('ui_laser'):
		draw_line(to_local(raycast_origin), to_local(raycast_collision), Color(1, 0, 0), 2, true)
		destination.position = raycast_collision

func _process(delta):
	var current_rotation = catKinematicBody.rotation
	if Input.is_action_pressed('ui_left'):
		if current_rotation < MAX_ROTATION:
			catKinematicBody.rotation += turning * delta
	if Input.is_action_pressed('ui_right'):
		if current_rotation > MIN_ROTATION:
			catKinematicBody.rotation -= turning * delta
	
	movement_dir = Input.get_vector("left","right","up","down")
	
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

func _physics_process(delta):	
	var nframes = 60
	
	var n_speed = movement_speed * movement_dir
	movement_velocity.x = calc_velocity_dir(n_speed.x, movement_velocity.x)
	movement_velocity.y = calc_velocity_dir(n_speed.y, movement_velocity.y)
	catKinematicBody.move_and_slide(movement_velocity)

	raycast.force_raycast_update()
	raycast_origin = raycast.get_global_position()
	
	if raycast.is_colliding():
		raycast_collision = raycast.get_collision_point()
	else:
		raycast_collision = get_global_transform().xform(raycast.get_cast_to())
	
	inc += 1
	update()

func calc_velocity_dir(n_speed, velocity_dir):
	if abs(n_speed) > abs(velocity_dir):
		velocity_dir = (5 * velocity_dir + n_speed) / 6
	else:
		if abs(velocity_dir) > 5:
			velocity_dir = (3 * velocity_dir + n_speed) / 4
		else:
			velocity_dir = 0

	return velocity_dir
