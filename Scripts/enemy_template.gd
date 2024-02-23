extends CharacterBody2D

@export var slowdown = 100
@export var enemyHealth = 50
@export var contactDamage = 5
var detection = false
var playerReference = null
var invulnerability = false

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
	if(area.owner.has_method('isWeapon') and !invulnerability): #if a weapon enters the hitbox area
		enemyHealth = enemyHealth - area.owner.weaponDamage
		invulnerability = true
		$HurtInvulnerability.start()
		print('Enemy Health: ' + str(enemyHealth))
		if(enemyHealth <= 0): #if it goes to or below 0 hp, remove from scene
			queue_free()
		else:
			var knockback_dir = area.owner.position.direction_to(self.position) #direction from weapon to self
			position += (knockback_dir * area.owner.weaponKnockback) * 5 #pushes the enemy back based on weapon knockback strength


func _on_hurt_invulnerability_timeout(): #damage invulnerability for 1s
	invulnerability = false
