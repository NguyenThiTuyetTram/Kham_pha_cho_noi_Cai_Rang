extends Area2D

@export var merchant_name := "Cô Sáu"
@export var product_name := "Trái cây"
@export var price := 50
@export var stock := 6

var player_near := false
var is_sulking := false
var name_label: Label
@onready var sprite: Sprite2D = $Sprite2D
@onready var fruit_icon: Sprite2D = $FruitIcon
var bob_phase := 0.0

func _ready() -> void:
	add_to_group("merchant_boat")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	fruit_icon.modulate = Color(1, 1, 1, 0.0)
	_create_nameplate()
	_create_exclamation()
	_update_nameplate()
	bob_phase = randf_range(0, TAU)

var exclamation_label: Label

func _create_exclamation() -> void:
	exclamation_label = Label.new()
	exclamation_label.text = "!"
	exclamation_label.position = Vector2(-20, -180)
	exclamation_label.size = Vector2(40, 40)
	exclamation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exclamation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	exclamation_label.add_theme_font_size_override("font_size", 48)
	exclamation_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	exclamation_label.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 0.8))
	exclamation_label.add_theme_constant_override("outline_size", 5)
	exclamation_label.visible = false
	add_child(exclamation_label)


func _process(delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	bob_phase += delta * 1.7
	sprite.position.y = sin(bob_phase) * 1.5
	sprite.rotation = sin(bob_phase * 0.72) * 0.025 + sin(bob_phase * 0.35) * 0.035
	sprite.scale = Vector2.ONE * (1.0 + sin(bob_phase * 1.3) * 0.012)
	var target_alpha := 1.0 if player_near and stock > 0 else 0.0
	fruit_icon.modulate.a = move_toward(fruit_icon.modulate.a, target_alpha, delta * 5.0)
	if player_near:
		fruit_icon.scale = Vector2.ONE * (0.92 + sin(Time.get_ticks_msec() / 170.0) * 0.06)
		var p = get_tree().current_scene.player
		if p:
			sprite.flip_h = global_position.x > p.global_position.x
	
	if exclamation_label != null:
		var scene = get_tree().current_scene
		if "available_quests" in scene and scene.available_quests.has(merchant_name) and not scene.quest_accepted:
			exclamation_label.visible = true
			exclamation_label.position.y = -180 + sin(bob_phase * 2.0) * 8.0
		else:
			exclamation_label.visible = false
			
	_update_nameplate()
	queue_redraw()


func purchase_feedback() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)
	tween.tween_property(self, "scale", Vector2.ONE, 0.18)


func reset_interaction_state() -> void:
	player_near = false
	is_sulking = false
	if fruit_icon != null:
		fruit_icon.modulate.a = 0.0


func get_blocking_center() -> Vector2:
	return global_position


func get_blocking_radius() -> float:
	return 118.0


func _update_prompt() -> void:
	if not player_near:
		return
	if stock <= 0:
		get_tree().current_scene.show_prompt("%s đã hết hàng" % merchant_name)
	else:
		get_tree().current_scene.show_prompt("Giữ E hỏi mua %s (Kho: %d)" % [product_name, stock])


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = Vector2(-150, -145)
	name_label.size = Vector2(300, 58)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38))
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(name_label)


func _update_nameplate() -> void:
	if name_label == null:
		return
	name_label.text = "%s\n%s - %dk" % [merchant_name, product_name, price]
	name_label.modulate.a = 1.0 if player_near else 0.78


func _draw() -> void:
	_draw_ellipse(Vector2(0, 28), Vector2(92, 34), Color(0.0, 0.0, 0.0, 0.24))
	if player_near:
		_draw_ellipse(Vector2(0, 20), Vector2(102, 39), Color(1.0, 0.76, 0.30, 0.055))


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(36):
		var angle: float = TAU * float(i) / 36.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		_update_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()
