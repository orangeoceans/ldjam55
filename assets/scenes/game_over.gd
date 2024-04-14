extends Control

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_stage_player_killed(score):
	visible = true
	$Control/BaddiesSlain.text = str(score)

func _on_play_again_button_button_down():
	visible = false
	print("PRESSED!")
	get_tree().change_scene_to_file("res://assets/main_scene.tscn")
