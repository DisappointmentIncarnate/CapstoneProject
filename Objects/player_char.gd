extends CharacterBody2D

@export var speed = 200 #@export allows change to the variable without opening the script

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
# documentation states this function runs 60 times a second regardless of actual framerate, recommended for movement and things that can collide
func _physics_process(_delta):
	get_movement_input()
	move_and_slide()
	pass
	
func get_movement_input():
	var direction = Input.get_vector("left", "right", "up", "down") # get_vector parameters (-x, +x, -y, +y)
	velocity = direction * speed
