extends Node2D

signal pressed_key(input_key)
signal reset_sequence_signal()
signal completed_sequence(command_key)

@export var SLIDER_BAR_PLAYER_MAX_POS: float = 2.0
@export var SLIDER_BAR_DOTS_NUMBER: int = 4
@export var BEAT_SPEED_MULT: float = 0.8
@export var BEAT_HIT_WINDOW: float = 0.03

@onready
var game_beat: Timer = $GameBeat
@onready
var slider_bar: Control = $GameUI/BeatSlider/SliderBar
@onready
var slider_bar_animation: AnimationPlayer = $GameUI/BeatSlider/SliderBar/SliderBarPlayer

var loops_elapsed: int = 0
@export var bar_progress: float

var sequences = {
	"UP":   [Vector2(0, 0), Vector2(0.25, 0), Vector2(0.5, 0), Vector2(0.75, 0)],
	"DOWN": [Vector2(0, 1), Vector2(0.25, 1), Vector2(0.5, 1), Vector2(0.75, 1)],
	"SPAWN": [Vector2(0, 0), Vector2(0.25, 1), Vector2(0.5, 2), Vector2(0.75, 3)],
}
var sequences_still_valid: = {}
var sequence_thus_far
var num_hits_thus_far: int
var can_reset_sequence: bool
var should_play_this_bar: bool

func reset_sequence():
	num_hits_thus_far = 0
	sequence_thus_far = []
	for key in sequences:
		sequences_still_valid[key] = true
	can_reset_sequence = false
	emit_signal("reset_sequence_signal")

# Called when the node enters the scene tree for the first time.
func _ready():
	game_beat.wait_time /= BEAT_SPEED_MULT
	slider_bar_animation.speed_scale = BEAT_SPEED_MULT
	game_beat.start()
	slider_bar_animation.play("slide")
	bar_progress = 0.0
	reset_sequence()
	can_reset_sequence = true
	should_play_this_bar = true

func look_up_hit(this_input):
	var at_least_one_hit_found = false
	for key in sequences:
		var sequence = sequences[key]
		if not sequences_still_valid[key]:
			continue
		if num_hits_thus_far < len(sequence) \
		and this_input == sequence[num_hits_thus_far][1] \
		and bar_progress >= sequence[num_hits_thus_far][0]-BEAT_HIT_WINDOW \
		and bar_progress <= sequence[num_hits_thus_far][0]+BEAT_HIT_WINDOW:
			if not at_least_one_hit_found:
				sequence_thus_far.append(sequence[num_hits_thus_far])
				at_least_one_hit_found = true
				emit_signal("pressed_key", this_input, bar_progress, true)
			if num_hits_thus_far+1 == len(sequence):
				emit_signal("completed_sequence", key)
				print(key)
				return true
		else:
			sequences_still_valid[key] = false
	if not at_least_one_hit_found:
		emit_signal("pressed_key", this_input, bar_progress, false)
		return false
	num_hits_thus_far += 1	
	return true

func handle_input():
	var this_input = null
	if Input.is_action_just_pressed("pressed_up"):
		this_input = 0
	elif Input.is_action_just_pressed("pressed_down"):
		this_input = 1
	elif Input.is_action_just_pressed("pressed_left"):
		this_input = 2
	elif Input.is_action_just_pressed("pressed_right"):
		this_input = 3
	
	if this_input != null and should_play_this_bar:
		var hit_found = look_up_hit(this_input)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bar_progress = (game_beat.wait_time - game_beat.time_left)/game_beat.wait_time
	if bar_progress >= 1-BEAT_HIT_WINDOW:
		if can_reset_sequence:
			should_play_this_bar = not should_play_this_bar
			if not should_play_this_bar:
				slider_bar.visible = false
			reset_sequence()
		bar_progress -= 1
	handle_input()

func _on_game_beat_timeout():
	slider_bar_animation.stop()
	if should_play_this_bar:
		slider_bar_animation.play("slide")
		slider_bar.visible = true
	can_reset_sequence = true


