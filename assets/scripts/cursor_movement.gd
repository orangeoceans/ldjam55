extends TextureRect

var viewport_rect
var viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_rect = get_viewport_rect()
	viewport = get_viewport()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = viewport.get_mouse_position()
	mouse_pos.x = clamp(mouse_pos.x, 0, viewport_rect.size.x)
	mouse_pos.y = clamp(mouse_pos.y, 0, viewport_rect.size.y)
	position = mouse_pos - size*scale/2.
