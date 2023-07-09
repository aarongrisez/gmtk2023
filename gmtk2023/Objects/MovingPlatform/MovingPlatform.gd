extends KinematicBody2D

export var currentAnimation = ""

func _ready():
	if currentAnimation != "":
		$AnimationPlayer.play(currentAnimation)
