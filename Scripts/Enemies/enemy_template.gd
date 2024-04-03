extends CharacterBody2D

@export var speed = 25
@export var enemyHealth = 50
@export var contactDamage = 5
var detection = false
var playerReference = null
var attackOrigin = null
var invulnerability = false
var knockback = 0

var possibilityList = ["green_slime", "blue_slime", "red_slime"]
var difficultyMult = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#Randomly selects an enemy from the list, and loads the speed, health, damage
	var enemy = possibilityList[randi() % possibilityList.size()]
	var scriptPath = "res://Scripts/Enemies/Collision/" + enemy + ".gd"
	var scriptLoad = load(scriptPath).new()

	speed = scriptLoad.get_speed() + calculateMult()
	enemyHealth = scriptLoad.get_health() * calculateMult()
	contactDamage = scriptLoad.get_contactDamage() + calculateMult()
	%AggroShape.shape.radius = scriptLoad.get_attackRange()
	
	#Selects and plays the animation associated with the enemy
	var animPath = "res://ArtAssets/Enemies/Animations/" + enemy + ".tres"
	$AnimatedSprite2D.set_sprite_frames(load(animPath))
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(delta):
	if detection and knockback == 0:
		var direction = self.global_position.direction_to(playerReference.global_position)
		velocity = direction * speed * delta
		move_and_collide(velocity)
		
		if(position.x - playerReference.global_position.x > 0): #whether or not to flip the animated sprite
			$AnimatedSprite2D.set_flip_h(false) #don't flip
		else:
			$AnimatedSprite2D.set_flip_h(true) #flip
			
	if knockback > 0:
		var knockback_dir = attackOrigin.global_position.direction_to(self.global_position) #direction from weapon to self
		velocity = (knockback_dir * knockback) * 5 #pushes the enemy back based on weapon knockback strength
		knockback = 0
		move_and_collide(velocity)
	else:
		move_and_collide(Vector2(0,0))
	
func _on_aggro_range_body_entered(body):
	if(body.has_method('get_movement_input')): #ensures the body is the player
		playerReference = body
		detection = true
		

func _on_aggro_range_body_exited(_body):
	playerReference = null
	detection = false

func _on_hitbox_area_entered(area):
	if(area.owner.has_method('isWeapon') and !invulnerability): #if a weapon enters the hitbox area
		attackOrigin = area.owner #tracks the weapon that hits the enemy
		if(area.owner.isDrop == true): #running over dropped item
			return
		enemyHealth = enemyHealth - area.owner.weaponDamage
		invulnerability = true
		$HurtInvulnerability.start()
		print('Enemy Health: ' + str(enemyHealth))
		if(enemyHealth <= 0): #if it goes to or below 0 hp, remove from scene
			call_deferred("drop_item")
			queue_free()
		else:
			knockback = area.owner.weaponKnockback

func _on_hurt_invulnerability_timeout(): #damage invulnerability for 1s
	invulnerability = false

func drop_item():
	#random chance to drop a heart item
	if randi()%2 == 0:
		var drop = preload("res://Scenes/Objects/heart.tscn").instantiate()
		drop.position = self.position
		get_parent().add_child(drop)

func calculateMult(): #calculates a number based on the player's current floor divided by 5, used to ramp up other stats as the player progresses.
	if(get_parent().get_parent().name == "Rooms"): #if the creature is setup in the rooms
		var currentFloor = get_parent().get_parent().get_floor()
		return ceil(currentFloor / 5.0)
	else:
		return 1
