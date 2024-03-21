extends Node2D

#basic_dagger.gd

var weaponDamage = 10 #value should be 10, but for testing purposes its set higher 
var weaponKnockback = 2.3
var weaponDuration = 0.2
var weaponSpeed = 50
var direction = Vector2.DOWN #default value of down
var isDrop = true

func isWeapon():
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
