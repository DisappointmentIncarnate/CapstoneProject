extends CharacterBody2D

@export var speed = 200 #@export allows change to the variable without opening the script
@export var playerHealth = 100
var alive = true

var invulnerability = false #whether or not to be invulnerable after taking a hit
var enemyContact = false #whether an enemy is touching the player
var damageOrigin #used as a temporary variable to keep reference

var weaponPath = preload('res://Objects/basic_dagger.tscn') #loading a basic weapon
var facingDirection = Vector2.DOWN #the direction the player faces
var weaponAttackTime #used to determine how often a weapon can be fired off
var weaponAction = false #flag to determine whether or now the player is currently performing an action with the weapon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if enemyContact and !invulnerability: #if the player is in contact with a damage source, and is not invulnerable
		take_damage()
		print("PLAYER HEALTH: " + str(playerHealth))
	if (Input.is_action_just_pressed("input1") and !weaponAction): #if you press the input, and you are currently not already performing an attack
		weapon_attack()
	
# documentation states this function runs 60 times a second regardless of actual framerate, recommended for movement and things that can collide
func _physics_process(_delta):
	if !weaponAction:
		get_movement_input()
	else:
		velocity = Vector2(0,0)
	move_and_slide()
	
func get_movement_input(): #left, right, up, down are set in the project setting's input mapping
	var direction = Input.get_vector("left", "right", "up", "down") # get_vector parameters (-x, +x, -y, +y)
	velocity = direction * speed
	#Basic sprite change based on direction, will replace later when finalized sprite and animation
	if(direction == Vector2.LEFT):
		$Sprite2D.set_frame(2)
		facingDirection = Vector2.LEFT
	elif(direction == Vector2.RIGHT):
		$Sprite2D.set_frame(4)
		facingDirection = Vector2.RIGHT
	elif(direction == Vector2.UP):
		$Sprite2D.set_frame(6)
		facingDirection = Vector2.UP
	elif(direction == Vector2.DOWN):
		$Sprite2D.set_frame(0)
		facingDirection = Vector2.DOWN

func _on_hitbox_body_entered(body):
	if(body.has_method('_on_aggro_range_body_entered')): #if the body that enters the range also has an aggro (i.e it's an enemy)
		damageOrigin = body; #variable to reference the origin of the damage
		enemyContact = true #flags whether or not the player is in contact with an enemy

func _on_hurt_invulnerability_timeout(): #after the timer wears out, invulnerability is disabled
	invulnerability = false

func take_damage(): #function to reduce player health, start damager invulernability timer
	playerHealth = playerHealth - damageOrigin.contactDamage
	$HurtInvulnerability.start()
	invulnerability = true
	if(playerHealth <= 0):
		alive = false
		queue_free()
	self.get_parent().get_node("Hud").set_health(playerHealth) #changes the hud's text with the new total health

func _on_hitbox_body_exited(body): #if the player no longer is in contact with an enemy
	if(body.has_method('_on_aggro_range_body_entered')):
		enemyContact = false
		
#flags that a weapon attack has started, generates an instance of the weapon, properly redirections the sprite
func weapon_attack():
	weaponAction = true
	var weapon = weaponPath.instantiate()
	weapon.direction = facingDirection
	weaponAttackTime = weapon.weaponDuration
	weapon.global_position = Vector2($WeaponDirection.global_position)
	weapon.look_at(position + facingDirection) 
	get_parent().add_child(weapon)
	$WeaponCooldown.set_wait_time(weaponAttackTime) #timer for attack cooldown
	$WeaponCooldown.start()

func _on_weapon_cooldown_timeout():
	weaponAction = false
