extends Control

var arrow_scenes = [
	preload("res://assets/scenes/arrow_up.tscn"),
	preload("res://assets/scenes/arrow_down.tscn"),
	preload("res://assets/scenes/arrow_left.tscn"),
	preload("res://assets/scenes/arrow_right.tscn")
]

var arrow_modulate_base = [
	Color(1, 0, 0, 0.4),
	Color(0, 1, 0, 0.4),
	Color(0, 0, 1, 0.4),
	Color(1, 0.86, 0, 0.4)
]

var sequence_loc = {
	"SPAWN": "Summon (40 MP)",
	"FAST": "Speed Up (Free)",
	"POWER": "Power Up (Free)",
	"MANA": "Restore MP (Free)",
	"HEAL": "Restore HP (20 MP)",
}

@onready
var arrow_sequence = $ArrowSequence
@onready
var name_text = $SequenceNameText

var ARROW_SCALE: Vector2 = Vector2(0.5, 0.5)
var SEQUENCE_SIZE_X: float = 200.

var arrow_list
var arrow_dir_list
var sequence_name

# Called when the node enters the scene tree for the first time.
func _ready():
	arrow_list = []
	arrow_dir_list = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_arrow_sequence(key: String, sequence):
	sequence_name = key
	name_text.text = sequence_loc[key]
	for arrow in sequence:
		var arrow_instance = arrow_scenes[arrow[1]].instantiate()
		arrow_sequence.add_child(arrow_instance)
		arrow_list.append(arrow_instance)
		arrow_dir_list.append(arrow[1])
		arrow_instance.position = Vector2(arrow[0]*SEQUENCE_SIZE_X, 0)
		arrow_instance.scale = ARROW_SCALE
		arrow_instance.modulate = arrow_modulate_base[arrow[1]]

func update_arrow_progress(still_valid: bool, num_hits_thus_far: int):
	for arrow_idx in arrow_list.size():
		if still_valid and arrow_idx <= num_hits_thus_far:
			arrow_list[arrow_idx].modulate = Color(arrow_modulate_base[arrow_dir_list[arrow_idx]])
			arrow_list[arrow_idx].modulate.a = 1
		else:
			arrow_list[arrow_idx].modulate = Color(0.5, 0.5, 0.5, 0.4)
