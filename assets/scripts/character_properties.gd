extends Sprite2D

@export var move_speed: float = 0.0
@export var inertia: float = 5 # 1/inertia is fraction of momentum changed per frame
@export var move_pattern: String = "NONE"
@export var size: float = texture.get_size().length()
@export var target: Node
@export var max_health: float = 100
@export var attack: float = 40
@export var effect_range: float = 60
@export var action_interval_seconds: float = 1

var window_size: Vector2
var window_center: Vector2
@onready
var action_timer: Timer = $ActionTimer
@onready
var effect_circle: Sprite2D = $EffectCircle
@onready
var effect_circle_animator: AnimationPlayer = $EffectCircle/EffectCircleAnimator

var is_active: bool
var momentum: Vector2
var current_health: float

# Called when the node enters the scene tree for the first time.
func _ready():
	effect_circle.visible = false
	effect_circle_animator.play("expand")
	window_size = get_parent().window_size
	window_center = window_size/2.
	momentum = Vector2(0,0)
	current_health = max_health
	action_timer.start()
	is_active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_active:
		move_character(delta)

func set_variables(character_type: String):
	match character_type:
		"GOODIE":
			move_speed = 100
			move_pattern = "TARGETED"
		"BADDIE":
			move_speed = 10
			move_pattern = "LINEAR"

func wobble_character_on_target(in_dir):
	var direction_len = in_dir.length()
	var direction
	if direction_len < size/2.:
		direction = Vector2(0.5-randf(), 0.5-randf()).normalized()
	else:
		direction = in_dir/direction_len
	return direction
	
func get_attacked(damage: float):
	current_health -= damage
	if current_health <= 0:
		is_active = false
	
func attack_target():
	if target and (target.position - position).length() < effect_range:
		target.get_attacked(attack)
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
	position += direction * move_speed * delta
	momentum += direction * 1./inertia
	var momentum_len = momentum.length()
	if momentum_len > 1:
		momentum = momentum/momentum_len

func _on_action_timer_timeout():
	if is_active:
		attack_target()

func _on_effect_circle_animator_animation_finished(anim_name):
	effect_circle_animator.stop()
	effect_circle.visible = false
