extends SceneTree

func _init():
	print("Building scenes...")
	
	# 1. UI Scene
	var ui = CanvasLayer.new()
	ui.name = "UI"
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(200, 80)
	panel.position = Vector2(20, 20)
	ui.add_child(panel)
	panel.owner = ui
	var money_label = Label.new()
	money_label.name = "MoneyLabel"
	money_label.text = "Tiền: 500k"
	money_label.position = Vector2(10, 10)
	panel.add_child(money_label)
	money_label.owner = ui
	var inv_label = Label.new()
	inv_label.name = "InvLabel"
	inv_label.text = "Kho: Trống"
	inv_label.position = Vector2(10, 40)
	panel.add_child(inv_label)
	inv_label.owner = ui
	
	var msg_panel = Panel.new()
	msg_panel.name = "MsgPanel"
	msg_panel.custom_minimum_size = Vector2(400, 100)
	msg_panel.position = Vector2(376, 500)
	msg_panel.visible = false
	ui.add_child(msg_panel)
	msg_panel.owner = ui
	var msg_label = Label.new()
	msg_label.name = "MsgLabel"
	msg_label.text = "Nhấn E để mua"
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	msg_panel.add_child(msg_label)
	msg_label.owner = ui
	
	var packed_ui = PackedScene.new()
	packed_ui.pack(ui)
	ResourceSaver.save(packed_ui, "res://ui.tscn")
	
	# 2. Player Scene
	var player = CharacterBody2D.new()
	player.name = "Player"
	var p_sprite = Sprite2D.new()
	p_sprite.texture = load("res://boat_real.png")
	player.add_child(p_sprite)
	p_sprite.owner = player
	var p_col = CollisionShape2D.new()
	var p_shape = RectangleShape2D.new()
	p_shape.size = Vector2(120, 120)
	p_col.shape = p_shape
	player.add_child(p_col)
	p_col.owner = player
	var camera = Camera2D.new()
	player.add_child(camera)
	camera.owner = player
	
	var particles = CPUParticles2D.new()
	particles.amount = 60
	particles.lifetime = 0.6
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(5, 15)
	particles.direction = Vector2(0, 1) # Bắn ra phía sau (vì thuyền hướng LÊN)
	particles.spread = 20.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 250.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 10.0
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	particles.scale_amount_curve = curve
	particles.color = Color(0.6, 0.9, 1.0, 0.8)
	particles.position = Vector2(0, 60)
	particles.z_index = -1
	player.add_child(particles)
	particles.owner = player
	
	var packed_player = PackedScene.new()
	packed_player.pack(player)
	ResourceSaver.save(packed_player, "res://player.tscn")
	
	# 3. Merchant Scene
	var merchant = Area2D.new()
	merchant.name = "Merchant"
	var m_sprite = Sprite2D.new()
	m_sprite.texture = load("res://fruit_boat_ai_clean.png")
	merchant.add_child(m_sprite)
	m_sprite.owner = merchant
	var m_col = CollisionShape2D.new()
	var m_shape = RectangleShape2D.new()
	m_shape.size = Vector2(250, 250)
	m_col.shape = m_shape
	merchant.add_child(m_col)
	m_col.owner = merchant
	
	var icon = Sprite2D.new()
	icon.name = "Icon"
	icon.texture = load("res://icon_fruit.png")
	icon.position = Vector2(0, -140)
	merchant.add_child(icon)
	icon.owner = merchant
	
	var packed_merchant = PackedScene.new()
	packed_merchant.pack(merchant)
	ResourceSaver.save(packed_merchant, "res://merchant.tscn")
	
	# 4. Main Scene
	var main = Node2D.new()
	main.name = "Main"
	
	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_CANVAS
	env_res.glow_enabled = true
	env_res.glow_intensity = 1.5
	env_res.glow_strength = 1.2
	env_res.glow_bloom = 0.2
	env.environment = env_res
	main.add_child(env)
	env.owner = main
	
	var packed_main = PackedScene.new()
	packed_main.pack(main)
	ResourceSaver.save(packed_main, "res://main.tscn")
	
	print("Done building scenes.")
	quit()
