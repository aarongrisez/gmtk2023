extends Navigation2D

onready var player = get_tree().get_current_scene().find_node("Player")
onready var destination = get_tree().get_current_scene().find_node("Destination")

var _current_path = []
var _platform_path = []

func _process(_delta):
	_follow_along_path()

func _update_debug_line():
	$DEBUG_path_line.clear_points()
	$DEBUG_path_line.add_point(player.position)
	for p in _current_path:
		$DEBUG_path_line.add_point(p)

# Check if all ascending sections have Y distance reachable by the character's jump
func _is_path_reachable(path):
	var previous = player.position
	for current in path:
		if previous.y > current.y and abs(previous.y - current.y) > player.get_jump_max_reach():
			return false
		previous = current
	return true
	
# Calculates an alternative path offsetting path start position
# it returns de closest valid path or empty array if not option available
func _calculate_alternate_path():
	var offset = Vector2(20, 0)
	var alt_1 = get_simple_path(player.position - offset, destination.position, true)
	var alt_2 = get_simple_path(player.position + offset, destination.position, true)

	var is_alt_1_reachable = _is_path_reachable(alt_1)
	var is_alt_2_reachable = _is_path_reachable(alt_2)

	if not (is_alt_1_reachable or is_alt_2_reachable):
		return []

	if is_alt_1_reachable and not is_alt_2_reachable:
		return alt_1

	if not is_alt_1_reachable and is_alt_2_reachable:
		return alt_2

	if alt_1[0].distance_to(destination.position) < alt_2[0].distance_to(destination.position):
		return alt_1

	return alt_2

# The player should jump in the following scenarios:
# - There is a blocker ahead.
# - It reaches a platform's edge, and its next step is at same level or above its current position
# - It's positioned just bellow it's target, and the target can be reached by jumping
func _should_jump(next_step):
	var y_distance = abs(player.position.y -  next_step.y)

	var result = (
			player.is_facing_jumpable_blocker() or
			(player.is_facing_edge() and player.position.y > next_step.y) or
			(y_distance < player.get_jump_max_reach() and player.position.y - 10 > next_step.y and abs(player.position.x - next_step.x) < 10)
			)
	return result


func _follow_along_path():
	if _current_path.size() == 0:
		return

	var next_step = _current_path[0]
	$DEBUG_next_step_marker.rect_position = next_step

	# Before stopping following path, I make sure the character is not jumping,
	# otherwise it could stop mid-jump, causing it to fall from a platform
	if player.position.distance_to(destination.position) < 20:
		_current_path = []
		player.make_idle()
		return

	if _should_jump(next_step):
		player.jump = true

	# remove point from path when reached
	if player.move_to_position(next_step):
		_current_path.remove(0)
		_update_debug_line()


# This method is called every 0.4 seconds by PathCalculationTimer node
func _on_PathCalculationTimer_timeout():
	var path = get_simple_path(player.position, destination.position)
	# if path has unreachable sections, calculate alternate paths
	# A section is considered unreachable when the Y distance between two points
	# is higher than the character's jump can reach.
	if not _is_path_reachable(path):
		path = _calculate_alternate_path()
	_current_path = path

	# Removing first point as it will always be the NPC current position.
	if path.size() > 0:
		_current_path.remove(0)

	_update_debug_line()
