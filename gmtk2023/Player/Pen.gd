extends Sprite

var MIN_ROTATION = -0.950007
var MAX_ROTATION = 0.965705
var speed = 250
export var turning = 1.0
var laser_on = false
var laser_strength = 0

class RaycastRenderInfo:
	var origin = Vector2(0, 0)
	var terminus = Vector2(0, 0)
	var is_colliding = false
	var has_prev = false
	var collision_normal = Vector2(0, 0)
	var prev_collision_normal = Vector2(0, 0)
	var prev_collision_hyp = 0
	var is_active = false
	var collision_hyp = 0
	
	func init(has_prev):
		self.has_prev = has_prev
		return self

var raycast_info = RaycastRenderInfo.new().init(false)
var raycast2_info = RaycastRenderInfo.new().init(true)

var movement_dir = Vector2(0, 0)
var movement_speed = 200
var movement_velocity = Vector2(0, 0)

onready var raycast = get_tree().get_current_scene().find_node("RayCast2D")
onready var raycast2 = get_tree().get_current_scene().find_node("RayCast2D2")
onready var destination = get_tree().get_current_scene().find_node("Destination")
onready var catKinematicBody = get_tree().get_current_scene().find_node("Cat").find_node("KinematicBody2D")

func _ready():
	pass # Replace with function body.

func render_raycast(raycast_render_info):
	var origin = raycast_render_info.origin
	var terminus = raycast_render_info.terminus
	var is_colliding = raycast_render_info.is_colliding
	var has_prev = raycast_render_info.has_prev
	var collision_normal = raycast_render_info.collision_normal
	var prev_collision_normal = raycast_render_info.prev_collision_normal
	var prev_collision_hyp = raycast_render_info.prev_collision_hyp
	var is_active = raycast_render_info.is_active
	
	var polygon = PoolVector2Array()
	var direction = (terminus - origin).normalized()
	var collision_angle = 0
	var collision_hyp = 0
	
	if not has_prev:
		polygon.push_back(to_local(origin) + Vector2(-1, 0))
		polygon.push_back(to_local(origin) + Vector2(1, -0.5))
	else:
		polygon.push_back(to_local(origin + prev_collision_normal.rotated(3.14 / 2) * prev_collision_hyp / 2))
		polygon.push_back(to_local(origin + prev_collision_normal.rotated(-3.14 / 2) * prev_collision_hyp / 2))

	if is_colliding:
		collision_angle = acos(direction.dot(collision_normal))
		collision_hyp = -2 / cos(collision_angle)
		polygon.push_back(to_local(terminus + collision_normal.rotated(3.14 / 2) * collision_hyp / 2))
		polygon.push_back(to_local(terminus + collision_normal.rotated(-3.14 / 2) * collision_hyp / 2))
	elif not has_prev:
		polygon.push_back(to_local(terminus) + Vector2(-1, 0))
		polygon.push_back(to_local(terminus) + Vector2(1, 0))
	else:
		polygon.push_back(to_local(terminus + Vector2(-1, 0)))
		polygon.push_back(to_local(terminus + Vector2(1, 0)))
		
	draw_colored_polygon(polygon, Color(1, 0, 0))
	
	raycast_render_info.collision_hyp = collision_hyp

func _draw():
	if laser_on:
		render_raycast(raycast_info)

		if raycast2.is_enabled():
			raycast2_info.prev_collision_normal = raycast_info.collision_normal
			raycast2_info.prev_collision_hyp = raycast_info.collision_hyp
			render_raycast(raycast2_info)

func _process(delta):
	pass

func _physics_process(delta):	
	var nframes = 60
	
	var current_rotation = catKinematicBody.rotation
	if Input.is_action_pressed('ui_laser'):
		laser_on = true
		laser_strength = 1
		destination.position = raycast_info.terminus
	if Input.is_action_just_released("ui_laser"):
		laser_on = false
	if Input.is_action_pressed('ui_left'):
		if current_rotation < MAX_ROTATION:
			catKinematicBody.rotation += turning * delta
	if Input.is_action_pressed('ui_right'):
		if current_rotation > MIN_ROTATION:
			catKinematicBody.rotation -= turning * delta

	movement_dir = Input.get_vector("left","right","up","down")
	Global.print_val_every(60, "movement_dir", movement_dir)
	var n_speed = movement_speed * movement_dir
	movement_velocity.x = calc_velocity_dir(n_speed.x, movement_velocity.x)
	movement_velocity.y = calc_velocity_dir(n_speed.y, movement_velocity.y)
	Global.print_val_every(60, "movement_velocity", movement_velocity)
	catKinematicBody.move_and_slide(movement_velocity)

	raycast.force_raycast_update()
	raycast_info.origin = raycast.get_global_position()
	raycast_info.is_colliding = raycast.is_colliding()
	
	if raycast.is_colliding():
		raycast_info.terminus = raycast.get_collision_point()
		raycast_info.collision_normal = raycast.get_collision_normal()

		var collider = raycast.get_collider()
		if collider.name == "Mirror":
			raycast2.set_enabled(true)
			var raycast_direction = (raycast_info.terminus - raycast_info.origin).normalized()
			var raycast2_direction = raycast_direction - 2 * (
				raycast_direction.dot(raycast_info.collision_normal)) * raycast_info.collision_normal
			raycast2_info.origin = raycast_info.terminus
			var raycast2_pos = raycast2.get_position()
			raycast2.set_global_position(raycast2_info.origin + raycast_info.collision_normal)
			raycast2.set_cast_to(raycast2_direction * 10000 + raycast2_pos)
			raycast2.force_raycast_update()
			raycast2_info.is_colliding = raycast2.is_colliding()
			if raycast2.is_colliding():
				raycast2_info.terminus = raycast2.get_collision_point()
				raycast2_info.collision_normal = raycast2.get_collision_normal()
			else:
				raycast2_info.terminus = raycast2_info.origin + raycast2_direction * 10000
		else:
			raycast2.set_enabled(false)
	else:
		raycast2.set_enabled(false)
		raycast_info.terminus = get_global_transform().xform(raycast.get_cast_to())
	
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
