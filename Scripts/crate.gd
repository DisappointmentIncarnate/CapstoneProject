extends Node2D

const ITEMS: Array = [preload("res://Objects/heart.tscn"), preload("res://Objects/Weapons/basic_spear.tscn"), preload("res://Objects/Weapons/basic_dagger.tscn")]
var remainTime = 1.0
var boxPosition

func _ready():
	pass # Replace with function body.

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
	var newItem = ITEMS[randi() % ITEMS.size()].instantiate()
	newItem.position = boxPosition
	add_child(newItem)
