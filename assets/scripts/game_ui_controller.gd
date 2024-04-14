extends Control

@onready
var sequences = get_parent().sequences
@onready
var ui_sequences = $SequencesList
var ui_sequences_list
@onready
var player_hpbar = $PlayerStats/HPBar
@onready
var player_mpbar = $PlayerStats/MPBar
@onready
var baddies_slain_counter = $PlayerStats/BaddiesSlain

var sequence_scene = preload("res://assets/scenes/sequence.tscn")
var baddies_slain

@export var game_stage: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var idx = 0
	baddies_slain = 0
	ui_sequences_list = []
	for key in sequences:
		var sequence_array = sequences[key]
		var sequence_instance = sequence_scene.instantiate()
		ui_sequences.add_child(sequence_instance)
		ui_sequences_list.append(sequence_instance)
		sequence_instance.position = Vector2(0, idx*75)
		sequence_instance.generate_arrow_sequence(key, sequence_array)
		idx += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player_hpbar.scale.x = game_stage.player_character.current_health/game_stage.player_character.max_health
	player_mpbar.scale.x = game_stage.player_mana/game_stage.player_max_mana

func _on_base_node_register_sequence_hit(still_valid_list, num_hits_thus_far):
	for ui_sequence in ui_sequences_list:
		var sequence_key = ui_sequence.sequence_name
		ui_sequence.update_arrow_progress(still_valid_list[sequence_key], num_hits_thus_far)

func _on_base_node_reset_sequence_signal(_should_play_this_bar):
	for ui_sequence in ui_sequences_list:
		var sequence_key = ui_sequence.sequence_name
		ui_sequence.update_arrow_progress(false, 0)

func _on_game_stage_baddie_killed():
	baddies_slain += 1
	baddies_slain_counter.text = str(baddies_slain)
