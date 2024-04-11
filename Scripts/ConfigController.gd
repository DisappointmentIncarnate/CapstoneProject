extends Node

var config = ConfigFile.new()
var SETTINGS_PATH = "user://config.ini" #save location of file (%appdata%/Godot/app_userdata/CapstoneProject/)

func _ready():
	if !FileAccess.file_exists(SETTINGS_PATH): #if file does not exist, create new file with defaults
		config.set_value("keybinding", "down", "Down")
		config.set_value("keybinding", "up", "Up")
		config.set_value("keybinding", "left", "Left")
		config.set_value("keybinding", "right", "Right")
		config.set_value("keybinding", "attack", "Z")
		config.set_value("keybinding", "swap_weapon", "Space")
		config.save(SETTINGS_PATH)
	else:
		config.load(SETTINGS_PATH) #otherwise load file
		
func save_keybinds(action, event):
	var event_name #variable stores actual keyboard event name
	if(event is InputEventKey):
		event_name = OS.get_keycode_string(event.physical_keycode)
		
	config.set_value("keybinding", action, event_name) #save keybind as "action=even_name"
	config.save(SETTINGS_PATH) #resave file
	
func load_keybinds():
	var keybinds = {} #dicitonary to be returned
	var inputs = config.get_section_keys("keybinding") #load section from file, returned as an array of keys
	for key in inputs:
		var input_event = InputEventKey.new() #new InputEventKey
		var event_name = config.get_value("keybinding", key) #returns value from the specified section and key
		input_event.keycode = OS.find_keycode_from_string(event_name)
		keybinds[key] = input_event #saves into new dictionary
	return keybinds
