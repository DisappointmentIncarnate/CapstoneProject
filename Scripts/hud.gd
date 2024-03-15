extends CanvasLayer

@onready var health_label = %Health
@onready var floor_label = %Floor

var health = 100
var dungeonFloor = 1

func _ready():
	update_health_label()
	update_floor_label()
	
func set_health(new_health):
	health = new_health
	update_health_label()
	
func update_health_label():
	health_label.set_text("Health: " + str(health))

func set_floor(new_floor):
	dungeonFloor = new_floor
	update_floor_label()
	
func update_floor_label():
	floor_label.set_text("Floor: " + str(dungeonFloor))
