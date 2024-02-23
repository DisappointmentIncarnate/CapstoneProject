extends StaticBody2D

func open():
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
