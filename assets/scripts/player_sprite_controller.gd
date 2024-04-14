extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func handle_input():
	if Input.is_action_pressed("pressed_up"):
		flip_h = false
		play("up")
	elif Input.is_action_pressed("pressed_down"):
		flip_h = false
		play("down")
	elif Input.is_action_pressed("pressed_left"):
		flip_h = true
		play("left")
	elif Input.is_action_pressed("pressed_right"):
		flip_h = false
		play("right")
	else:
		flip_h = false
		play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_input()
