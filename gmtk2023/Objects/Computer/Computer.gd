extends Node2D


onready var destination = get_tree().get_current_scene().find_node("Destination")

func send_notification():
	$AnimatedSprite.play("notification")
	destination.position = position

func cancel_notification():
	$AnimatedSprite.play("idle")
