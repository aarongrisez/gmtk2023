extends Sprite

func _ready():
	update_text()

func _process(_delta):
	update_text()

func update_text():
	if Global.currently_notifying:
		visible = true
	else:
		visible = false

