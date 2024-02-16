extends CharacterBody2D

@export var slowdown = 100
@export var enemyHealth = 50
@export var contactDamage = 5
var detection = false
var playerReference = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(_delta):
	if detection:
		position += (playerReference.position - position)/slowdown #move the enemy towards the position of the player, at a specific speed (higher slowdown, slower the speed)
	move_and_collide(Vector2(0,0))
	
func _on_aggro_range_body_entered(body):
	playerReference = body
	detection = true

func _on_aggro_range_body_exited(_body):
	playerReference = null
	detection = false

func _on_hitbox_area_entered(area):
	if(area.owner.has_method('isWeapon')): #if a weapon enters the hitbox area
		enemyHealth = enemyHealth - area.owner.weaponDamage
		print('Enemy Health: ' + str(enemyHealth))
		if(enemyHealth <= 0): #if it goes to or below 0 hp, remove from scene
			queue_free()
