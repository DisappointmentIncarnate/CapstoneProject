extends CharacterBody2D

@export var slowdown = 100
@export var enemyHealth = 30
@export var contactDamage = 5
var detection = false
var playerReference = null
var invulnerability = false

var attackSpeed = 2.5
var projectilePath = preload('res://Scenes/Objects/Weapons/basic_arrow.tscn')
var attacking = false

var knockback = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(_delta):
	if detection and knockback == 0:
		#calculate distance from players x and y
		var distanceX = abs(position.x - playerReference.global_position.x)
		var distanceY = abs(position.y - playerReference.global_position.y)
		if(distanceX < distanceY): #if its faster to move towards the x-axis
			global_position.x += (playerReference.global_position.x - global_position.x)/slowdown
		else: #if its faster to move towards the y-axis
			global_position.y += (playerReference.global_position.y - global_position.y)/slowdown
		if(!attacking): #start firing projectiles
			$AttackSpeed.set_wait_time(attackSpeed)
			attacking = true;
			$AttackSpeed.start()
	if knockback > 0:
		var knockback_dir = playerReference.global_position.direction_to(self.global_position) #direction from weapon to self
		velocity = (knockback_dir * knockback) * 5 #pushes the enemy back based on weapon knockback strength
		knockback = 0
		move_and_collide(velocity)
	
func _on_aggro_range_body_entered(body):
	playerReference = body
	detection = true

func _on_aggro_range_body_exited(_body):
	playerReference = null
	detection = false

func _on_hitbox_area_entered(area):
	if(area.owner.has_method('isProjectile') and area.owner.fromPlayer == false): #ignores own projectiles
		return
	if(area.owner.has_method('isWeapon') and !invulnerability): #if a weapon enters the hitbox area
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
	weapon.direction = self.position.direction_to(playerReference.global_position)
	weapon.global_position = self.global_position
	weapon.look_at(position + self.position.direction_to(playerReference.global_position)) 
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
