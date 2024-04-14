extends Node2D

@onready
var baddie_timer: Timer = $BaddieSpawnTimer

@export var BADDIE_SPAWN_SECONDS: int = 6

var character_scenes = {
	"GOODIE": preload("res://assets/scenes/goodie.tscn"),
	"BADDIE": preload("res://assets/scenes/baddie.tscn"),
}

var ENEMY_SPAWN_CIRCLE_RADIUS = 400

var all_goodies
var all_baddies
var window_size: Vector2

func get_random_circle_point():
	var center = window_size/2.
	var radius = ENEMY_SPAWN_CIRCLE_RADIUS

	var angle = randf() * 2 * PI
	
	var x = center.x + radius * cos(angle)
	var y = center.y + radius * sin(angle)
	
	return Vector2(x, y)

func _ready():
	all_goodies = []
	all_baddies = []
	window_size = get_viewport().size
	baddie_timer.wait_time = BADDIE_SPAWN_SECONDS
	baddie_timer.start()

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
	var character_instance = character_scenes[character_key].instantiate()
	add_child(character_instance)
	character_instance.set_variables(character_key)
	return character_instance

func spawn_baddie():
	var baddie_instance = spawn_character("BADDIE")
	baddie_instance.position = get_random_circle_point()
	all_baddies.append(baddie_instance)

func spawn_goodie():
	var goodie_instance = spawn_character("GOODIE")
	goodie_instance.position = get_viewport().get_mouse_position()
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
		baddie.queue_free()
		return false
	return true

func _on_base_node_completed_sequence(command_key):
	match command_key:
		"SPAWN":
			spawn_goodie()

func _on_baddie_spawn_timer_timeout():
	spawn_baddie()
