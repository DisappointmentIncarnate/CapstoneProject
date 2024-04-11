extends Node2D

func _ready():
	randomize() #randomize ensures that room generation is truly randomized and does not generate the same numbers every time the game is reloaded

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://Scenes/Ui/menu.tscn")
