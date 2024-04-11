extends Control

@onready var menu_button = preload("res://Scenes/Ui/menu_input_button.tscn")
@onready var action_list = $Panel/MarginContainer/VBoxContainer/ScrollContainer/List

#Flags and references
var remapping = false
var action_to_remap = null
var button_to_remap = null

var action_dict = { #dictionary of action inputs and what they should be named in the menu, not actual keybinds
	"down" : "Move Down",
	"up" : "Move Up",
	"left" : "Move Left",
	"right" : "Move Right",
	"attack" : "Attack",
	"swap_weapon" : "Swap Weapon"
}

func _ready():
	load_settings()
	create_action_list()
	
func create_action_list(): #This function's purpose is to populate the options menu, does not have anything to do with customizing keybinds
	#removes any default items, there's 1 on scene as an example
	for item in action_list.get_children():
		item.queue_free()
	
	#adds new buttons from the items in the dictionary
	for actions in action_dict:
		var new_button = menu_button.instantiate()
		
		var action_label = new_button.find_child("LabelAction")
		action_label.text = action_dict[actions] #replaces label text with the properly formatted one in the dictionary
		
		var input_label = new_button.find_child("LabelInput")
		var events = InputMap.action_get_events(actions) #if there are events within the project settings
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)") #replaces the label text with the actual event from settings
		else:
			input_label.text = "" #otherwise leave blank
			
		action_list.add_child(new_button) #add button
		new_button.pressed.connect(on_input_button_pressed.bind(new_button, actions)) #adds a signal between button and the on_input_button_pressed function
		
func on_input_button_pressed(button, action): #if any of the buttons are pressed
	if !remapping:
		#set flags and referneces
		remapping = true
		button_to_remap = button
		action_to_remap = action
		button.find_child("LabelInput").text = "Input Button..."

func _input(event): #default godot input function,
	if remapping:
		if(event is InputEventKey): #checks if the input is a key, not accepting mouse inputs
			#removes old input action, and addes new action with the event key
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			ConfigController.save_keybinds(action_to_remap, event)
			
			#update text 
			button_to_remap.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")
			
			#reset all flags / references
			remapping = false
			button_to_remap = null
			action_to_remap = null

func _on_reset_pressed():
	#Load from default project settings
	InputMap.load_from_project_settings()
	for action in action_dict: #go through the action dictionary
		var event = InputMap.action_get_events(action)
		if event.size() > 0: #if event exists
			ConfigController.save_keybinds(action, event[0])
	create_action_list()

func _on_return_pressed(): #hide control panel
	self.visible = false

func load_settings(): #go through saved keybinds, remove default actions and re-add actions using the saved keybinds
	var keybinds = ConfigController.load_keybinds()
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
