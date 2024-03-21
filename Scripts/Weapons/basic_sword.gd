extends Node2D

#basic_sword.gd

var weaponDamage = 15 #value should be 10, but for testing purposes its set higher 
var weaponKnockback = 5.3
var weaponDuration = 0.6
var weaponSpeed = 1 #set to 1 because the weapon does not reach outwards
var direction = Vector2.DOWN #default value of down
var isDrop = true

func isWeapon():
	pass

func _ready(): #after the object is made, immediately start the timer
	if(!isDrop):
		$DurationTimer.set_wait_time(weaponDuration)
		$DurationTimer.start()
		
		#Directional rotations used because the weapon 'sweeps' in an area
		if(direction == Vector2.UP):
			$".".set_rotation_degrees(-30) 
		elif(direction == Vector2.DOWN):
			$".".set_rotation_degrees(-210)
		elif(direction == Vector2.RIGHT):
			$".".set_rotation_degrees(60)
		else:
			$".".set_rotation_degrees(-100)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_duration_timer_timeout(): #after the timer runs out, delete the item
	queue_free()

func _physics_process(delta): #the weapon comes out like a projectile
	if(!isDrop):
		position += direction * weaponSpeed * delta
		rotate(-.07)
