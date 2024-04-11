extends Control

func _on_return_pressed():
	get_tree().change_scene_to_file("res://Scenes/Ui/menu.tscn")

func focus_button():
	$Panel/MarginContainer/VBoxContainer/Return.grab_focus()

func update():
	if(self.get_parent().get_node("Hud") != null):
		$Panel/MarginContainer/VBoxContainer/Score.text = "Highest Floor Reached: " + str(self.get_parent().get_node("Hud").get_floor())
