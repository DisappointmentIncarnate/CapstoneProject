extends Node2D

const ITEMS: Array = [preload("res://Objects/heart.tscn") ]
const WEAPONS: Array = [preload("res://Objects/Weapons/basic_spear.tscn"), preload("res://Objects/Weapons/basic_dagger.tscn"), preload("res://Objects/Weapons/basic_sword.tscn")]
var remainTime = 1.0
var boxPosition

func _ready():
	$StaticBody2D/BoxShape.set_deferred("disabled", false)
	$Hitbox.set_deferred("monitoring", true)
	$Unbroken.visible = true
	$Broken.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_hitbox_area_entered(area):
	if(area.owner.has_method('isWeapon')): #if the player attacks the crate
		boxPosition = area.position
		$StaticBody2D/BoxShape.set_deferred("disabled", true)
		$Hitbox.set_deferred("monitoring", false)
		$Unbroken.visible = false
		$Broken.visible = true
		call_deferred("dropItem")

func dropItem():
	var newItem
	if(randi() % 7 == 0):
		newItem = WEAPONS[randi() % ITEMS.size()].instantiate()
	elif(randi() % 6 == 0):
		newItem = ITEMS[randi() % ITEMS.size()].instantiate()
		
	if(newItem != null):
		newItem.position = boxPosition
		add_child(newItem)
