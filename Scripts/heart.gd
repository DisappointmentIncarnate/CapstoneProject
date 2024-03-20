extends Node2D

var floorTime = 5

func _ready():
	$Timer.set_wait_time(floorTime)
	$Timer.start()
	
func _on_timer_timeout():
	queue_free()

func _on_hitbox_body_entered(body):
	if(body.has_method('get_movement_input')): #if the player attacks the crate
		body.set_health(10) #add 10 hp to player
		queue_free()
