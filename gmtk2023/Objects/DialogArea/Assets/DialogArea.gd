extends Area2D

export(String, MULTILINE) var text = ""

func _on_DialogArea_body_entered(body):
	if body.has_method("is_player"):
		Global.text_box = text

func _on_DialogArea_body_exited(body):
	if body.has_method("is_player"):
		if Global.text_box == text:
			Global.text_box = ""

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			position = get_global_mouse_position()
