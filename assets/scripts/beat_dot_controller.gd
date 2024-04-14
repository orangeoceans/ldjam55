extends TextureRect

@export var DOT_INDEX: int
var dot_bar_fraction: float

@onready
var root_node: Node
# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_tree().current_scene
	dot_bar_fraction = float(DOT_INDEX)/(root_node.SLIDER_BAR_DOTS_NUMBER)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if root_node.bar_progress > dot_bar_fraction or root_node.bar_progress < 0:
		scale = Vector2(1.5, 1.5)
	else:
		scale = Vector2(1, 1)
