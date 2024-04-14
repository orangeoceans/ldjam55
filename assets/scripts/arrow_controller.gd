extends Control

@export var slider_bar: Control
@export var dot: Control

var SLIDER_BAR_STARTING_X: float = 100.0

var arrow_modulate_base = [
	Color(1, 0, 0, 0.4),
	Color(0, 1, 0, 0.4),
	Color(0, 0, 1, 0.4),
	Color(1, 0.86, 0, 0.4)
]

var arrow_scenes = [
	preload("res://assets/scenes/arrow_up.tscn"),
	preload("res://assets/scenes/arrow_down.tscn"),
	preload("res://assets/scenes/arrow_left.tscn"),
	preload("res://assets/scenes/arrow_right.tscn")
]

var arrows_thus_far

# Called when the node enters the scene tree for the first time.
func _ready():
	arrows_thus_far = []

func place_arrow(input_key, bar_progress, is_hit):
	var arrow_instance = arrow_scenes[input_key].instantiate()
	add_child(arrow_instance)
	if bar_progress <= 0:
		arrow_instance.position = Vector2(SLIDER_BAR_STARTING_X-dot.size.x, slider_bar.position.y+arrow_instance.size.y/2.)
	else:
		arrow_instance.position = Vector2(slider_bar.position.x-arrow_instance.size.x/2., slider_bar.position.y+arrow_instance.size.y/2.)
	if not is_hit:
		arrow_instance.scale = Vector2(0.5, 0.5)
	arrows_thus_far.append(arrow_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_base_node_pressed_key(input_key, bar_progress, is_hit):
	place_arrow(input_key, bar_progress, is_hit)

func _on_base_node_reset_sequence_signal(_should_play_this_bar):
	for arrow in arrows_thus_far:
		arrow.queue_free()
	arrows_thus_far = []

