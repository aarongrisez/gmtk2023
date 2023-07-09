extends Node2D


onready var destination = get_tree().get_current_scene().find_node("Destination")

func send_notification():
	$AnimatedSprite.play("notification")
	$AudioStreamPlayer.play(0)
	destination.position = position

func cancel_notification():
	$AnimatedSprite.play("idle")

func notify():
	send_notification() # Replace with function body.
	$Timer.start(1.5)

func _on_Timer_timeout():
	cancel_notification()
