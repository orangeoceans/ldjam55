extends Node2D

signal baddie_killed()
signal player_killed(score)

@onready
var baddie_timer: Timer = $BaddieSpawnTimer
@onready
var fast_modifier_timer: Timer = $FastModifierTimer
@onready
var power_modifier_timer: Timer = $PowerModifierTimer

@export var baddie_spawn_seconds: float = 6.
@export var modifier_time_seconds: float = 4.

@export var player_max_mana: float = 100
var player_mana: float

var character_scene = preload("res://assets/scenes/character.tscn")

var ENEMY_SPAWN_CIRCLE_RADIUS = 400

var all_goodies
var all_baddies
var window_size: Vector2

var goodies_speed_mult: float = 1.
var goodies_power_mult: float = 1.

var player_character
var baddies_killed: int = 0

func get_random_circle_point():
	var center = window_size/2.
	var radius = ENEMY_SPAWN_CIRCLE_RADIUS

	var angle = randf() * 2 * PI
	
	var x = center.x + radius * cos(angle)
	var y = center.y + radius * sin(angle)
	
	return Vector2(x, y)

func _ready():
	player_mana = player_max_mana
	all_goodies = []
	all_baddies = []
	window_size = get_viewport().size
	player_character = spawn_character("PLAYER")
	player_character.position = Vector2(window_size.x/2.+10, window_size.y/2.-30)
	baddie_timer.wait_time = baddie_spawn_seconds
	baddie_timer.start()
	fast_modifier_timer.wait_time = modifier_time_seconds
	power_modifier_timer.wait_time = modifier_time_seconds


func _process(delta):
	var alive_goodies = []
	for goodie_idx in all_goodies.size():
		var should_keep = process_goodie(goodie_idx, delta)
		if should_keep:
			alive_goodies.append(all_goodies[goodie_idx])
	all_goodies = alive_goodies

	var alive_baddies = []
	for baddie_idx in all_baddies.size():
		var should_keep = process_baddie(baddie_idx, delta)
		if should_keep:
			alive_baddies.append(all_baddies[baddie_idx])
	all_baddies = alive_baddies
	
	if player_character.current_health <=99:
		emit_signal("player_killed", baddies_killed)
		baddie_timer.stop()

func change_mana(change: float):
	player_mana += change
	player_mana = clamp(player_mana, 0, 100)

func seek_nearest_character(this_character, character_list):
	var nearest_dist = 99999.9
	var nearest_character = null
	for character in character_list:
		if not character.is_active:
			continue
		var distance = this_character.position.distance_to(character.position)
		if distance < nearest_dist:
			nearest_dist = distance
			nearest_character = character
	return nearest_character

func spawn_character(character_key):
	var character_instance = character_scene.instantiate()
	add_child(character_instance)
	character_instance.set_variables(character_key)
	return character_instance

func spawn_baddie():
	var baddie_instance = spawn_character("BADDIE")
	baddie_instance.position = get_random_circle_point()
	baddie_instance.target = player_character
	all_baddies.append(baddie_instance)

func spawn_goodie():
	var goodie_instance = spawn_character("GOODIE")
	var viewport_rect = get_viewport_rect()
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_pos.x = clamp(mouse_pos.x, 0, viewport_rect.size.x)
	mouse_pos.y = clamp(mouse_pos.y, 0, viewport_rect.size.y)
	goodie_instance.position = mouse_pos
	all_goodies.append(goodie_instance)

func move_baddie(baddie, delta: float):
	baddie.move_character(delta)

func move_goodie(goodie, delta: float):
	goodie.move_character(delta)
		
func process_goodie(goodie_idx, delta: float):
	var goodie = all_goodies[goodie_idx]
	if goodie.current_health <= 0:
		goodie.queue_free()
		return false
	if not goodie.target:
		goodie.target = seek_nearest_character(goodie, all_baddies)
	return true
	
func process_baddie(baddie_idx, delta: float):
	var baddie = all_baddies[baddie_idx]
	if baddie.current_health <= 0:
		emit_signal("baddie_killed")
		baddie.queue_free()
		baddies_killed += 1
		return false
	return true

func _on_base_node_completed_sequence(command_key, mana_cost):
	if not mana_cost or mana_cost <= player_mana:
		change_mana(-mana_cost)
		match command_key:
			"SPAWN":
				spawn_goodie()
			"FAST":
				goodies_speed_mult = 3.
				fast_modifier_timer.start()
			"POWER":
				goodies_power_mult = 2.
				power_modifier_timer.start()
			"MANA":
				change_mana(20)
			"HEAL":
				player_character.change_health(20)

func _on_baddie_spawn_timer_timeout():
	spawn_baddie()
	baddie_spawn_seconds -= 0.1
	baddie_timer.wait_time = baddie_spawn_seconds

func _on_fast_modifier_timer_timeout():
	goodies_speed_mult = 1.

func _on_power_modifier_timer_timeout():
	goodies_power_mult = 1.
