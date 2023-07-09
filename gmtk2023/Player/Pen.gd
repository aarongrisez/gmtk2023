extends Sprite

var MIN_ROTATION = -0.950007
var MAX_ROTATION = 0.965705
var speed = 250
export var turning = 1.0
var laser_on = false
var laser_strength = 0

var raycast_origin = Vector2(0, 0)
var raycast_collision = Vector2(0, 0)
var raycast_collision_normal = Vector2(0, 0)
var raycast_mirrored = false
var raycast2_origin = Vector2(0, 0)
var raycast2_collision = Vector2(0, 0)
var raycast2_normal = Vector2(0, 0)

var movement_dir = Vector2(0, 0)
var movement_speed = 200
var movement_velocity = Vector2(0, 0)

onready var raycast = get_tree().get_current_scene().find_node("RayCast2D")
onready var raycast2 = get_tree().get_current_scene().find_node("RayCast2D2")
onready var destination = get_tree().get_current_scene().find_node("Destination")
onready var catKinematicBody = get_tree().get_current_scene().find_node("Cat").find_node("KinematicBody2D")

func _ready():
	pass # Replace with function body.
	
func _draw():
	if laser_on:
		var polygon = PoolVector2Array()
		var raycast_direction = (raycast_collision - raycast_origin).normalized()
		
		polygon.push_back(to_local(raycast_origin) + Vector2(-1, 0))
		polygon.push_back(to_local(raycast_origin) + Vector2(1, -0.5))
		
		if raycast.is_colliding():
			var raycast_collision_angle = acos(raycast_direction.dot(raycast_collision_normal))
			var raycast_collision_hyp = -2 / cos(raycast_collision_angle)
			polygon.push_back(to_local(raycast_collision + raycast_collision_normal.rotated(3.14 / 2) * raycast_collision_hyp / 2))
			polygon.push_back(to_local(raycast_collision + raycast_collision_normal.rotated(-3.14 / 2) * raycast_collision_hyp / 2))
		else:
			polygon.push_back(to_local(raycast_collision) + Vector2(1, 0))
			polygon.push_back(to_local(raycast_collision) + Vector2(-1, 0))

		draw_colored_polygon(polygon, Color(1, 0, 0))

		if raycast2.is_enabled():
			polygon = PoolVector2Array()
			polygon.push_back(to_local(raycast2_origin + Vector2(-1, 0) / get_scale()))
			polygon.push_back(to_local(raycast2_origin + Vector2(1, 0) / get_scale()))
			polygon.push_back(to_local(raycast2_collision + Vector2(1, 0) / get_scale()))
			polygon.push_back(to_local(raycast2_collision + Vector2(-1, 0) / get_scale()))
			draw_colored_polygon(polygon, Color(1, 0, 0))

func _process(delta):
	pass
	
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
	
	var current_rotation = catKinematicBody.rotation
	if Input.is_action_pressed('ui_laser'):
		laser_on = true
		laser_strength = 1
		destination.position = raycast_collision
	if Input.is_action_just_released("ui_laser"):
		laser_on = false
	if Input.is_action_pressed('ui_left'):
		if current_rotation < MAX_ROTATION:
			catKinematicBody.rotation += turning * delta
	if Input.is_action_pressed('ui_right'):
		if current_rotation > MIN_ROTATION:
			catKinematicBody.rotation -= turning * delta

	movement_dir = Input.get_vector("left","right","up","down")
	
	var n_speed = movement_speed * movement_dir
	movement_velocity.x = calc_velocity_dir(n_speed.x, movement_velocity.x)
	movement_velocity.y = calc_velocity_dir(n_speed.y, movement_velocity.y)
	catKinematicBody.move_and_slide(movement_velocity)

	raycast.force_raycast_update()
	raycast_origin = raycast.get_global_position()
	
	if raycast.is_colliding():
		raycast_collision = raycast.get_collision_point()
		raycast_collision_normal = raycast.get_collision_normal()

		var collider = raycast.get_collider()
		if collider.name == "Mirror":
			raycast2.set_enabled(true)
			var raycast_direction = (raycast_collision - raycast_origin).normalized()
			var raycast2_direction = raycast_direction - 2 * (
				raycast_direction.dot(raycast_collision_normal)) * raycast_collision_normal
			raycast2_origin = raycast_collision
			var raycast2_pos = raycast2.get_position()
			raycast2.set_global_position(raycast2_origin - Vector2(0.5, 0.5))
			raycast2.set_cast_to(raycast2_direction * 10000 + raycast2_pos)
			raycast2.force_raycast_update()
			if raycast2.is_colliding():
				raycast2_collision = raycast2.get_collision_point()
			else:
				raycast2_collision = raycast2_origin + raycast2_direction * 10000
		else:
			raycast2.set_enabled(false)
	else:
		raycast2.set_enabled(false)
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
