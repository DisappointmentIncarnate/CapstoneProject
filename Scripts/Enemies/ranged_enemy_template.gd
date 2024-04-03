extends CharacterBody2D

@export var slowdown = 100
@export var enemyHealth = 30
@export var contactDamage = 5
var detection = false
var playerReference = null
var attackOrigin = null
var invulnerability = false
var knockback = 0

var attackSpeed = 2.5
var projectilePath = preload('res://Scenes/Objects/Weapons/basic_arrow.tscn')
var attacking = false

var possibilityList = ["archer_1", "archer_2", "archer_3", "archer_4"]
var difficultyMult = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#Randomly selects an enemy from the list, and loads the speed, health, damage
	var enemy = possibilityList[randi() % possibilityList.size()]
	var scriptPath = "res://Scripts/Enemies/Ranged/" + enemy + ".gd"
	var scriptLoad = load(scriptPath).new()

	slowdown = scriptLoad.get_slowdown() 
	enemyHealth = scriptLoad.get_health() 
	contactDamage = scriptLoad.get_contactDamage()
	attackSpeed = scriptLoad.get_attackSpeed()
	%AggroShape.shape.radius = scriptLoad.get_attackRange()
	
	#Selects and plays the animation associated with the enemy
	var animPath = "res://ArtAssets/Enemies/Animations/" + enemy + ".tres"
	$AnimatedSprite2D.set_sprite_frames(load(animPath))
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(_delta):
	if detection and knockback == 0:
		#calculate distance from players x and y
		var distanceX = abs(global_position.x - playerReference.global_position.x)
		var distanceY = abs(global_position.y - playerReference.global_position.y)
		if(distanceX < distanceY): #if its faster to move towards the x-axis
			move_and_collide(Vector2((playerReference.global_position.x - global_position.x)/slowdown, 0))
		else: #if its faster to move towards the y-axis
			move_and_collide(Vector2(0, (playerReference.global_position.y - global_position.y)/slowdown))
		
		if(position.x - playerReference.global_position.x > 0): #whether or not to flip the animated sprite
			$AnimatedSprite2D.set_flip_h(false) #don't flip
		else:
			$AnimatedSprite2D.set_flip_h(true) #flip
			
		if(!attacking): #start firing projectiles
			$AttackSpeed.set_wait_time(attackSpeed)
			attacking = true;
			$AttackSpeed.start()
	if knockback > 0:
		var knockback_dir = attackOrigin.global_position.direction_to(self.global_position) #direction from weapon to self
		velocity = (knockback_dir * knockback) * 5 #pushes the enemy back based on weapon knockback strength
		knockback = 0
		move_and_collide(velocity)
	
func _on_aggro_range_body_entered(body):
	if(body.has_method('get_movement_input')):
		playerReference = body
		detection = true

func _on_aggro_range_body_exited(_body):
	playerReference = null
	detection = false

func _on_hitbox_area_entered(area):
	if(area.owner.has_method('isProjectile') and area.owner.fromPlayer == false): #ignores own projectiles
		return
	if(area.owner.has_method('isWeapon') and !invulnerability): #if a weapon enters the hitbox area
		attackOrigin = area.owner
		enemyHealth = enemyHealth - area.owner.weaponDamage
		invulnerability = true
		$HurtInvulnerability.start()
		if(enemyHealth <= 0): #if it goes to or below 0 hp, remove from scene
			call_deferred("drop_item")
			queue_free()
		else:
			knockback = area.owner.weaponKnockback


func _on_hurt_invulnerability_timeout(): #damage invulnerability for 1s
	invulnerability = false

func _on_attack_speed_timeout():
	#almost the same setup as player using weapon except positions are based upon relation to playerposition
	var weapon = projectilePath.instantiate()
	if(playerReference == null): #if the player moves out of range during a queued attack
		attacking = false
		return
	weapon.direction = self.global_position.direction_to(playerReference.global_position)
	weapon.global_position = self.position
	weapon.look_at(position + self.global_position.direction_to(playerReference.global_position)) 
	weapon.isDrop = false
	weapon.fromPlayer = false
	get_parent().add_child(weapon)
	attacking = false;
	
func drop_item():
	#random chance to drop a heart item
	if randi()%2 == 0:
		var drop = preload("res://Scenes/Objects/heart.tscn").instantiate()
		drop.position = self.position
		get_parent().add_child(drop)
