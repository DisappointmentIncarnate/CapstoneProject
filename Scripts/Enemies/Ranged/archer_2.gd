class_name archer_2 extends Node

var slowdown = 100
var enemyHealth = 40
var contactDamage = 0
var attackSpeed = 2.1
var attackRange = 110

func get_slowdown():
	return slowdown
	
func get_health():
	return enemyHealth

func get_contactDamage():
	return contactDamage

func get_attackSpeed():
	return attackSpeed

func get_attackRange():
	return attackRange
