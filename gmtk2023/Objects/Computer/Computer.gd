extends Node2D


onready var destination = get_tree().get_current_scene().find_node("Destination")

func send_notification():
	$AnimatedSprite.play("notification")
	$AudioStreamPlayer.play(0)
	destination.position = position
	Global.currently_notifying = true

func cancel_notification():
	$AnimatedSprite.play("idle")
	Global.currently_notifying = false

func notify():
	send_notification() # Replace with function body.
	$Timer.start(1.5)

func _on_Timer_timeout():
	cancel_notification()
