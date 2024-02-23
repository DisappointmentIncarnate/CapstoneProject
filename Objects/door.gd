extends StaticBody2D

func open():
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false

func close():
	$CollisionShape2D.set_deferred("disabled", false)
	$Sprite2D.visible = true
