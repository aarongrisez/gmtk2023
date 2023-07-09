extends Sprite

var MIN_ROTATION = -0.950007
var MAX_ROTATION = 0.965705
var MIN_ZOOM = 0.25
var MAX_ZOOM = 0.50
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
	var child = null
	var raycast = null
	
	func init(has_prev, raycast, child):
		self.has_prev = has_prev
		self.raycast = raycast
		self.child = child
		return self
		
	func deactivate_children():
		if self.child != null:
			self.child.is_active = false
			self.child.deactivate_children()

var movement_dir = Vector2(0, 0)
var movement_speed = 200
var movement_velocity = Vector2(0, 0)

onready var scene = get_tree().get_current_scene()
onready var raycast = scene.find_node("RayCast2D")
onready var raycast2 = scene.find_node("RayCast2D2")
onready var raycast3 = scene.find_node("RayCast2D3")
onready var raycast4 = scene.find_node("RayCast2D4")
onready var raycast5 = scene.find_node("RayCast2D5")
onready var raycast6 = scene.find_node("RayCast2D6")
onready var raycast7 = scene.find_node("RayCast2D7")
onready var raycast8 = scene.find_node("RayCast2D8")
onready var destination = scene.find_node("Destination")
onready var catKinematicBody = scene.find_node("Cat").find_node("KinematicBody2D")
onready var camera = catKinematicBody.find_node("Camera2D")

onready var raycast8_info = RaycastRenderInfo.new().init(true, raycast8, null)
onready var raycast7_info = RaycastRenderInfo.new().init(true, raycast7, raycast8_info)
onready var raycast6_info = RaycastRenderInfo.new().init(true, raycast6, raycast7_info)
onready var raycast5_info = RaycastRenderInfo.new().init(true, raycast5, raycast6_info)
onready var raycast4_info = RaycastRenderInfo.new().init(true, raycast4, raycast5_info)
onready var raycast3_info = RaycastRenderInfo.new().init(true, raycast3, raycast4_info)
onready var raycast2_info = RaycastRenderInfo.new().init(true, raycast2, raycast3_info)
onready var raycast_info = RaycastRenderInfo.new().init(false, raycast, raycast2_info)

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
		polygon.push_back(to_local(terminus) + Vector2(1, 0))
		polygon.push_back(to_local(terminus) + Vector2(-1, 0))
	else:
		polygon.push_back(to_local(terminus + Vector2(-1, 0)))
		polygon.push_back(to_local(terminus + Vector2(1, 0)))

	draw_colored_polygon(polygon, Color(1, 0, 0))
	
	raycast_render_info.collision_hyp = collision_hyp
	
	var child = raycast_render_info.child
	
	if child != null and child.is_active:
		child.prev_collision_normal = raycast_render_info.collision_normal
		child.prev_collision_hyp = raycast_render_info.collision_hyp
		render_raycast(child)

func _draw():
	if laser_on:
		render_raycast(raycast_info)

func _process(delta):
	pass
		
func process_child_raycast(raycast_info, prev_raycast_info):
	raycast_info.is_active = true
	var raycast = raycast_info.raycast
	var prev_raycast_direction = (prev_raycast_info.terminus - prev_raycast_info.origin).normalized()
	var raycast_direction = prev_raycast_direction - 2 * (
		prev_raycast_direction.dot(prev_raycast_info.collision_normal)) * prev_raycast_info.collision_normal
	raycast_info.origin = prev_raycast_info.terminus
	var raycast_pos = raycast.get_position()
	raycast.set_global_position(raycast_info.origin + prev_raycast_info.collision_normal)
	raycast.set_cast_to(raycast_direction * 10000 + raycast_pos)
	raycast.force_raycast_update()
	raycast_info.is_colliding = raycast.is_colliding()
	if raycast.is_colliding():
		raycast_info.terminus = raycast.get_collision_point()
		raycast_info.collision_normal = raycast.get_collision_normal()

		if laser_on:
			destination.position = raycast_info.terminus

		var collider = raycast.get_collider()
		if "Mirror" in collider.name and raycast_info.child != null:
			process_child_raycast(raycast_info.child, raycast_info)
	else:
		raycast_info.terminus = raycast_info.origin + raycast_direction * 10000

func _physics_process(delta):	
	var nframes = 60
	
	var current_rotation = catKinematicBody.rotation
	if Input.is_action_pressed('ui_laser'):
		laser_on = true
		laser_strength = 1
	if Input.is_action_just_released("ui_laser"):
		laser_on = false
	if Input.is_action_pressed('ui_left'):
		if current_rotation < MAX_ROTATION:
			catKinematicBody.rotation += turning * delta
	if Input.is_action_pressed('ui_right'):
		if current_rotation > MIN_ROTATION:
			catKinematicBody.rotation -= turning * delta
			
	
	var add_offset = Vector2(-120, -70)		
	var current_zoom = camera.zoom
	if Input.is_action_pressed('ui_down'):
		if current_zoom.x < MAX_ZOOM:
			camera.zoom.x += 0.01
			camera.zoom.y += 0.01
			camera.offset = Vector2(100, 50) - ((camera.zoom.x / MIN_ZOOM) - 1) * add_offset
	if Input.is_action_pressed('ui_up'):
		if current_zoom.y > MIN_ZOOM:
			camera.zoom.x -= 0.01
			camera.zoom.y -= 0.01
			camera.offset = Vector2(100, 50) - ((camera.zoom.x / MIN_ZOOM) - 1) * add_offset

	movement_dir = Input.get_vector("left","right","up","down")

	var gas_left = Input.get_action_strength("left")
	var gas_right = Input.get_action_strength("right")

	var gas_up = Input.get_action_strength("up")
	var gas_down = Input.get_action_strength("down")
	movement_dir = Vector2(gas_right - gas_left, gas_down - gas_up)

	var n_speed = movement_speed * movement_dir
	movement_velocity.x = calc_velocity_dir(n_speed.x, movement_velocity.x)
	movement_velocity.y = calc_velocity_dir(n_speed.y, movement_velocity.y)
	catKinematicBody.move_and_slide(movement_velocity)
	
	raycast_info.deactivate_children()

	raycast.force_raycast_update()
	raycast_info.origin = raycast.get_global_position()
	raycast_info.is_colliding = raycast.is_colliding()
	
	if raycast.is_colliding():
		raycast_info.terminus = raycast.get_collision_point()
		raycast_info.collision_normal = raycast.get_collision_normal()
		Global.print_val_every(60, "raycast collision point", raycast_info.terminus)
		Global.print_val_every(60, "raycast collision normal", raycast_info.collision_normal)
		
		if laser_on:
			destination.position = raycast_info.terminus

		var collider = raycast.get_collider()
		if "Mirror" in collider.name:
			process_child_raycast(raycast2_info, raycast_info)
	else:
		raycast_info.terminus = get_global_transform().xform(raycast.get_cast_to())
		Global.print_val_every(60, "raycast collision point", raycast_info.terminus)
	
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
