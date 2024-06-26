extends Node2D

const ENEMY_SCENES: Dictionary = {"COLLISION" : preload("res://Scenes/Objects/Enemies/enemy_template.tscn"), "RANGED" : preload("res://Scenes/Objects/Enemies/ranged_enemy_template.tscn")}
const BOXES: Dictionary = {"Crate" : preload("res://Scenes/Objects/crate.tscn")}
var enemy_num: int
@onready var doors_node = get_node("Doors")
@onready var enemy_positions = get_node("Enemy")
@onready var player_detection: Area2D = get_node("Detector")
@onready var crate_positions = get_node("Crate")

var floor_cleared = false #custom signal to emit when the player reaches the end of the floor

func _ready():
	enemy_num = enemy_positions.get_child_count()
	open_door()
	spawn_crates()
	
func open_door():
	for door in doors_node.get_children():
		door.open()
		
func close_door():
	for door in doors_node.get_children():
		door.close()

func spawn_enemies():
	for enemy in enemy_positions.get_children():
		var mob
		if(randi_range(1,4) != 4 ): #rolls 1-4, if 1-3 spawn collsion based enemy, if 4 spawn range based enemy
			mob = ENEMY_SCENES.COLLISION.instantiate()
		else:
			mob = ENEMY_SCENES.RANGED.instantiate()
		mob.global_position = enemy.position
		call_deferred("add_child", mob)
		
func spawn_crates():
	for location in crate_positions.get_children():
		if(randi() % 2 == 0): #50/50 chance that the box will spawn
			var box = BOXES.Crate.instantiate()
			box.position = location.position
			call_deferred("add_child", box)

func _on_detector_body_entered(_body): #area the player steps in to spawn enemies (by the entrance of the room)
	player_detection.queue_free()
	spawn_enemies()
	close_door()


func _on_child_exiting_tree(node): #checks if enemy node is removed from the tree
	if(node.has_method('_on_aggro_range_body_entered')): #if an enemy is removed
		enemy_killed()

func enemy_killed(): #checks whether or not to open the doors, based on enemy count
	enemy_num -=1
	if enemy_num == 0:
		open_door()

func _on_floor_end_body_entered(body): #if the player enters the stair tile
	if(body.has_method('get_movement_input')):
		floor_cleared = true
