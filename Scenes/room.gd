extends Node2D

const ENEMY_SCENES: Dictionary = {"ENEMY_TEMPLATE" : preload("res://Objects/enemy_template.tscn")}
var enemy_num: int

@onready var entrance_node: Node2D = get_node("Entrance")
@onready var doors_node: Node2D = get_node("Doors")
@onready var enemy_positions = get_node("Enemy")
@onready var player_detection: Area2D = get_node("Detector")

func _ready():
	enemy_num = enemy_positions.get_child_count()
	
func open_door():
	for door in doors_node.get_children():
		door.open()

func spawn_enemies():
	for enemy in enemy_positions.get_children():
		var mob = ENEMY_SCENES.ENEMY_TEMPLATE.instantiate()
		#var mob_death = mob.connect("tree_exited", self, "on_enemy_killed")
		mob.position = enemy.position
		call_deferred("add_child", mob)

func _on_detector_body_entered(body): #area the player steps in to spawn enemies (by the entrance of the room)
	player_detection.queue_free()
	spawn_enemies()


func _on_child_exiting_tree(node):
	if(node.has_method('_on_aggro_range_body_entered')): #if an enemy is removed
		enemy_killed()

func enemy_killed(): #checks whether or not to open the doors, based on enemy count
	enemy_num -=1
	if enemy_num == 0:
		open_door()
