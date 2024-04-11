extends CharacterBody2D

@export var speed = 200 #@export allows change to the variable without opening the script
@export var playerHealth = 100

var invulnerability = false #whether or not to be invulnerable after taking a hit
var enemyContact = false #whether an enemy is touching the player
var damageOrigin #used as a temporary variable to keep reference

var weaponPath  #variable used for loading a weapon
var facingDirection = Vector2.DOWN #the direction the player faces
var weaponAttackTime #used to determine how often a weapon can be fired off
var weaponAction = false #flag to determine whether or now the player is currently performing an action with the weapon

var onWeapon = false #flag to check whether or not the player is currently standing on a weapon
var newWeapon #reference to object on floor, used to swap weapons

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if enemyContact and !invulnerability: #if the player is in contact with a damage source, and is not invulnerable
		take_damage(damageOrigin.contactDamage)
	if (Input.is_action_just_pressed("attack") and !weaponAction): #if you press the input, and you are currently not already performing an attack
		weapon_attack(false)
	if (Input.is_action_just_pressed("swap_weapon") and onWeapon):
		swap_weapon()
	
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
		$AnimatedSprite2D.play("walk_left")
		facingDirection = Vector2.LEFT
	elif(direction == Vector2.RIGHT):
		$AnimatedSprite2D.play("walk_right")
		facingDirection = Vector2.RIGHT
	elif(direction == Vector2.UP):
		$AnimatedSprite2D.play("walk_up")
		facingDirection = Vector2.UP
	elif(direction == Vector2.DOWN):
		$AnimatedSprite2D.play("walk_down")
		facingDirection = Vector2.DOWN
	else:
		$AnimatedSprite2D.stop()
	move_and_collide(Vector2(0,0))

func _on_hitbox_body_entered(body):
	if(body.has_method('_on_aggro_range_body_entered')): #if the body that enters the range also has an aggro (i.e it's an enemy)
		damageOrigin = body #variable to reference the origin of the damage
		enemyContact = true #flags whether or not the player is in contact with an enemy
		
func _on_hurt_invulnerability_timeout(): #after the timer wears out, invulnerability is disabled
	invulnerability = false

func take_damage(damageNum): #function to reduce player health, start damager invulernability timer
	playerHealth = playerHealth - damageNum
	$HurtInvulnerability.start()
	invulnerability = true
	if(playerHealth <= 0):
		gameover()
	self.get_parent().get_node("Hud").set_health(playerHealth) #changes the hud's text with the new total health

func _on_hitbox_body_exited(body): #if the player no longer is in contact with an enemy
	if(body.has_method('_on_aggro_range_body_entered')):
		enemyContact = false
		
#flags that a weapon attack has started, generates an instance of the weapon, properly redirections the sprite
func weapon_attack(isDrop):
	$AnimatedSprite2D.stop()
	weaponAction = true
	if(weaponPath == null): #if theres ever a reason this breaks, the default weapon is the dagger
		weaponPath = load('res://Scenes/Objects/Weapons/basic_dagger.tscn')
		
	var weapon = weaponPath.instantiate()
	weapon.direction = facingDirection
	weapon.global_position = Vector2($WeaponDirection.global_position)
	weapon.look_at(position + facingDirection) 
	weaponAttackTime = weapon.weaponDuration
	weapon.isDrop = isDrop
	if(isDrop):
		weaponAttackTime = 0.1
	$WeaponCooldown.set_wait_time(weaponAttackTime) #timer for attack cooldown
	$WeaponCooldown.start()
	
	get_parent().add_child(weapon)

func _on_weapon_cooldown_timeout():
	weaponAction = false
	
func swap_weapon():
	weapon_attack(true)
	weaponPath = load(newWeapon.scene_file_path) #makes a path to the weapon that was chosen)
	remove_weapon(newWeapon)

func _on_hitbox_area_entered(area): #function to detect whether an area2d is overlapping the player's hitbox
	if(area.owner.has_method('isProjectile') and area.owner.fromPlayer == false): #detecting projectile
		take_damage(area.owner.weaponDamage)
	elif(area.owner.has_method('isWeapon')): #detecting if over a weapon
		onWeapon = true
		newWeapon = area.owner

func _on_hitbox_area_exited(area): #if the player is no longer on a area2d
	if(area == null):
		onWeapon = false
	elif(area.owner != null and area.owner.has_method('isWeapon') ):
		onWeapon = false

func remove_weapon(item): #removes the item from the ground
	item.queue_free()

func set_health(add): #method to add hp but never exceeding max hp
	if(playerHealth + add > 100): #max health of 100, never overflow
		playerHealth = 100
	else:
		playerHealth = playerHealth + add
	self.get_parent().get_node("Hud").set_health(playerHealth)
	
func gameover():
	queue_free()
	self.get_parent().get_node("Gameover").visible = true
	self.get_parent().get_node("Gameover").global_position = self.global_position
	self.get_parent().get_node("Gameover").focus_button()
	self.get_parent().get_node("Gameover").update()
