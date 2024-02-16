extends Node2D

var weaponDamage = 10 
var weaponKnockback = 1
var weaponDuration = 0.7
var weaponSpeed = 30
var direction = Vector2.DOWN #default value of down

func isWeapon():
	pass

func _ready(): #after the object is made, immediately start the timer
	$DurationTimer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_duration_timer_timeout(): #after the timer runs out, delete the item
	queue_free()

func _physics_process(delta): #the weapon comes out like a projectile
	position += direction * weaponSpeed * delta
