extends Node2D

#Arrays that carry the room scenes for generation
const BEGINNING: Array = [preload('res://Scenes/Rooms/room_b0.tscn'), preload('res://Scenes/Rooms/room_b1.tscn')]
const MIDDLE: Array = [preload('res://Scenes/Rooms/room_m0.tscn'), preload('res://Scenes/Rooms/room_m1.tscn'), preload('res://Scenes/Rooms/room_m2.tscn')]
const END: Array = [preload('res://Scenes/Rooms/room_e0.tscn'), preload('res://Scenes/Rooms/room_e1.tscn')]

const TILE = 16 #texture size used for move rooms by the correct tile size (16x16 for all textures made)
const FLOOR_INDEX = 1 #texture id for the floor (1 is the grass path texture id)
const WALLS = 7 #texture id for the walls (7 is the id for the brick tile)

@export var currentFloor = 1
@export var floorSize: int
var finalRoom

@onready var PlayerChar = get_parent().get_node("PlayerChar") #get reference to player character

func _ready():
	spawn_rooms()
	
func _process(_delta):
	if(finalRoom != null and finalRoom.floor_cleared == true): #if the player enters the staircase in the final room
		currentFloor+=1
		self.get_parent().get_node("Hud").set_floor(currentFloor) 
		delete_rooms()
		spawn_rooms()
		
func spawn_rooms():
	floorSize = 2 + (currentFloor) #calculates floor size based on how many floors the player has been through
	var previousRoom
	for x in floorSize:
		var room
		if x == 0: #if beginning room
			room = BEGINNING[randi() % BEGINNING.size()].instantiate() #randi() is a random int, mod ensures it actually is within the confines of the array
			PlayerChar.position = room.get_node("PlayerSpawn").position #since its a spawn room, set the players position to the spawn point
		else: #if they are not the first room, we need to make connections
			if x == floorSize-1: #make last room, 1 off because start index 0
				room = END[randi() % END.size()].instantiate()
				finalRoom = room #save reference to final room
			else: #middle rooms
				room = MIDDLE[randi() % MIDDLE.size()].instantiate()
				
			#Calculate previous room's exit based on the exit door
			var previousRoomTile = previousRoom.get_node("TileMap") 
			var previousRoomDoor = previousRoom.get_node("Doors/Exit")
			var previousRoomExit = previousRoomTile.local_to_map(previousRoomDoor.position)
		
			var hallwayHeight = 3
			for y in hallwayHeight: #make a 3 tile long hallway going up
				#set_cell(x, y, tile_id, tile atlast coordinates) 
				previousRoomTile.set_cell(-2, previousRoomExit + Vector2i(-2,-y), WALLS, Vector2(0,0)) #left wall 
				previousRoomTile.set_cell(-1, previousRoomExit + Vector2i(-1,-y), FLOOR_INDEX, Vector2(1,0)) #left tile
				previousRoomTile.set_cell(0, previousRoomExit + Vector2i(0,-y), FLOOR_INDEX, Vector2(2,0)) #right tile
				previousRoomTile.set_cell(1, previousRoomExit + Vector2i(1,-y), WALLS, Vector2(0,0)) #right wall
		
			#calculates the position of the new room, based on the previous room's exit + hallway, 
			var roomTileMap = room.get_node("TileMap")
			room.position = (previousRoomDoor.global_position + Vector2.UP * roomTileMap.get_used_rect().size.y * TILE + Vector2.UP * (hallwayHeight * TILE) ) + Vector2.LEFT * roomTileMap.local_to_map(room.get_node("Doors/Entrance").position).x * TILE
		
		add_child(room)
		previousRoom = room

func delete_rooms(): #remove all child nodes (removing all rooms)
	for x in get_children():
		x.queue_free()
