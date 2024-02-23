extends Node2D

#Arrays that carry the room scenes for generation
const BEGINNING: Array = [preload('res://Scenes/Rooms/room_b0.tscn')]
const MIDDLE: Array = [preload('res://Scenes/Rooms/room_m0.tscn')]
const END: Array = [preload('res://Scenes/Rooms/room_e0.tscn')]

@export var levelSize = 5
@onready var PlayerChar = get_parent().get_node("PlayerChar") #get reference to player character

func _ready():
	spawn_rooms()
	
func spawn_rooms():
	var previousRoom
	for x in levelSize:
		var room
		
		if x == 0:
			room = BEGINNING[randi() % BEGINNING.size()].instantiate() #randi() is a random int, mod ensures it actually is within the confines of the array
			PlayerChar.position = room.get_node("PlayerSpawn").position #since its a spawn room, set the players position to the spawn point
			
		add_child(room)
		previousRoom = room
