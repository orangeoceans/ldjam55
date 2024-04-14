extends Node2D

var game_stage: Node2D

@export var move_speed: float = 0.0
@export var inertia: float = 5 # 1/inertia is fraction of momentum changed per frame
@export var move_pattern: String = "NONE"
@export var size: float
@export var target: Node
@export var max_health: float = 100
@export var decay_per_second: float = -1
@export var attack: float = 0
@export var effect_range: float = 100
@export var action_interval_seconds: float = 1

var character_scenes = {
	"PLAYER": preload("res://assets/scenes/player_big.tscn"),
	"GOODIE_1": preload("res://assets/scenes/goodie_1.tscn"),
	"GOODIE_2": preload("res://assets/scenes/goodie_2.tscn"),
	"BADDIE_1": preload("res://assets/scenes/baddie_1.tscn"),
	"BADDIE_2": preload("res://assets/scenes/baddie_2.tscn"),
}

var window_size: Vector2
var window_center: Vector2
@onready
var action_timer: Timer = $ActionTimer
@onready
var effect_circle: Sprite2D = $EffectCircle
@onready
var effect_circle_animator: AnimationPlayer = $EffectCircle/EffectCircleAnimator
@onready
var health_bar: ColorRect = $HealthBar
var sprite

var is_active: bool
var is_goodie: bool
var momentum: Vector2
var current_health: float

# Called when the node enters the scene tree for the first time.
func _ready():
	game_stage = get_parent()
	effect_circle.visible = false
	effect_circle_animator.play("expand")
	window_size = game_stage.window_size
	window_center = window_size/2.
	momentum = Vector2(0,0)
	current_health = max_health
	action_timer.start()
	is_active = true
	is_goodie = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_active:
		move_character(delta)
		if decay_per_second > 0:
			change_health(-delta * decay_per_second)

func set_variables(character_type: String):
	var key: String
	match character_type:
		"PLAYER":
			health_bar.visible = false
			scale = Vector2(0.3, 0.3)
			key = "PLAYER"
		"GOODIE":
			move_speed = 50
			move_pattern = "TARGETED"
			decay_per_second = 5
			attack = 25
			is_goodie = true
			key = "GOODIE_%s" % randi_range(1,2)
		"BADDIE":
			move_speed = 10
			move_pattern = "LINEAR"
			attack = 2
			is_goodie = false
			key = "BADDIE_%s" % randi_range(1,2)
	sprite = character_scenes[key].instantiate()
	add_child(sprite)
	size = sprite.sprite_frames.get_frame_texture("default", 0).get_size().length()

func wobble_character_on_target(in_dir):
	var direction_len = in_dir.length()
	var direction
	if direction_len < size/2.:
		direction = Vector2(0.5-randf(), 0.5-randf()).normalized()
	else:
		direction = in_dir/direction_len
	return direction
	
func change_health(change: float):
	current_health += change
	health_bar.scale.x = current_health/max_health
	if current_health <= 0:
		current_health = 0
		is_active = false
	elif current_health > 100:
		current_health = 100
	
func attack_target():
	if target and (target.position - position).length() < effect_range:
		var actual_attack = attack
		if is_goodie:
			actual_attack *= game_stage.goodies_power_mult
		print(actual_attack)
		target.change_health(-actual_attack)
		effect_circle.visible = true
		effect_circle_animator.stop()
		effect_circle_animator.play("expand")

func move_character(delta: float, raw_dir = null):
	var pos_delta = Vector2(0,0)
	var direction = Vector2(0,0)
	if raw_dir != null:
		direction = wobble_character_on_target(raw_dir)
		direction = (direction+momentum).normalized()
	elif target and move_pattern == "TARGETED":
		direction = wobble_character_on_target(target.position - position)
		direction = (direction+momentum).normalized()
	else:
		match move_pattern:
			"LINEAR":
				direction = wobble_character_on_target(window_center - position)
				direction += momentum
			"TARGETED":
				pass
			"NONE":
				pass
	var delta_pos = direction * move_speed * delta
	if is_goodie:
		delta_pos *= game_stage.goodies_speed_mult
	position += delta_pos
	momentum += direction * 1./inertia
	var momentum_len = momentum.length()
	if momentum_len > 1:
		momentum = momentum/momentum_len

func _on_action_timer_timeout():
	if is_active:
		attack_target()

func _on_effect_circle_animator_animation_finished(_anim_name):
	effect_circle_animator.stop()
	effect_circle.visible = false
