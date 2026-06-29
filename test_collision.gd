extends SceneTree

func _init():
	var game = load("res://scenes/Game.tscn").instantiate()
	var shore = game.get_node("Shore_cai_rang")
	if not shore:
		print("Shore_cai_rang NOT FOUND!")
	else:
		print("Shore_cai_rang found. Class: ", shore.get_class())
		print("Layer: ", shore.collision_layer, " Mask: ", shore.collision_mask)
		for c in shore.get_children():
			print(" Child: ", c.name, " Class: ", c.get_class())
			if c is CollisionPolygon2D:
				print("  Polygon disabled: ", c.disabled)
				print("  Build mode: ", c.build_mode)
				
	var boat = game.get_node("PlayerBoat")
	if boat:
		print("PlayerBoat Layer: ", boat.collision_layer, " Mask: ", boat.collision_mask)
	
	quit()
