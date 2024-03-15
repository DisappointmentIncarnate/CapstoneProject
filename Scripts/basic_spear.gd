extends Node2D

var weaponDamage = 20 #value should be 10, but for testing purposes its set higher 
var weaponKnockback = 7.2
var weaponDuration = 0.3
var weaponSpeed = 45
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
