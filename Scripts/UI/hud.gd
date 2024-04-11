extends CanvasLayer

@onready var floor_label = %Floor
@onready var health_bar = %Healthbar

var health = 100
var max_health = 100
var dungeonFloor = 1

func _ready():
	update_healthbar()
	update_floor_label()
	
func set_health(new_health):
	health = new_health
	var healthcolor
	if(health <= 30): #lowest health, set color to red
		healthcolor = load("res://ArtAssets/HUD/redhealth (64 x 16).png")
	elif(health <= 60): #middle, set to yellow
		healthcolor = load("res://ArtAssets/HUD/yellowhealth (64 x 16).png")
	else: #default color for healthbar, green
		healthcolor = load("res://ArtAssets/HUD/greenhealth (64 x 16).png")
	health_bar.set_progress_texture(ImageTexture.create_from_image(healthcolor.get_image())) #set progress bar, image
	update_healthbar()
	
func update_healthbar():
	health_bar.value = health

func set_floor(new_floor):
	dungeonFloor = new_floor
	update_floor_label()
	
func update_floor_label():
	floor_label.set_text("Floor: " + str(dungeonFloor))
	
func get_floor():
	return dungeonFloor
