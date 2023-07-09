extends Label

var completed = false

func _ready():
	update_text()

func _process(_delta):
	update_text()

func update_text():
	text = str(Global.current_food + Global.collected_food) + " of " + str(Global.max_food) + " collected"
	
	if Global.collected_food == Global.max_dish:
		if completed:
			return
		completed = true
		$CPUParticles2D.emitting = true
		#Global.text_box = "Congrulations"
