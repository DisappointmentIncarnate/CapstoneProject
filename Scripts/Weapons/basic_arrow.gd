extends Node2D

#basic_arrow.gd

var weaponDamage = 10 #value should be 10
var weaponKnockback = 2.3
var weaponDuration = 50
var weaponSpeed = 100
var direction = Vector2.DOWN #default value of down
var isDrop = true
var fromPlayer = true

func isWeapon():
	pass

func isProjectile():
	pass

func _ready(): #after the object is made, immediately start the timer
	if(!isDrop):
		$DurationTimer.set_wait_time(weaponDuration)
		$DurationTimer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_duration_timer_timeout(): #after the timer runs out, delete the item
	queue_free()

func _physics_process(delta): #the weapon comes out like a projectile
	if(!isDrop):
		position += direction * weaponSpeed * delta

func _on_hitbox_body_entered(body): #when the arrow hits something
	if(fromPlayer == false and body.has_method('_on_aggro_range_body_entered')): #if the arrow is fired from an enemy and hits an enemy
		return
	elif(fromPlayer == true and body.has_method('get_movement_input')): #if the arrow is fired from the player and hits the player
		return
	queue_free()
