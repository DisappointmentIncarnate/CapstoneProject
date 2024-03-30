extends CharacterBody2D

@export var speed = 25
@export var enemyHealth = 50
@export var contactDamage = 5
var detection = false
var playerReference = null
var invulnerability = false
var knockback = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(delta):
	if detection and knockback == 0:
		var direction = self.global_position.direction_to(playerReference.global_position)
		velocity = direction * speed * delta
		move_and_collide(velocity)
	if knockback > 0:
		var knockback_dir = playerReference.global_position.direction_to(self.global_position) #direction from weapon to self
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
		if(area.owner.isDrop == true): #running over dropped item
			return
		enemyHealth = enemyHealth - area.owner.weaponDamage
		invulnerability = true
		$HurtInvulnerability.start()
		print('Enemy Health: ' + str(enemyHealth))
		if(enemyHealth <= 0): #if it goes to or below 0 hp, remove from scene
			queue_free()
		else:
			knockback = area.owner.weaponKnockback


func _on_hurt_invulnerability_timeout(): #damage invulnerability for 1s
	invulnerability = false
