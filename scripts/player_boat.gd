extends CharacterBody2D

@export var max_speed := 240.0
@export var acceleration := 720.0
@export var friction := 560.0
@export var river_bounds := Rect2(160, 120, 1600, 820)

const CARGO_TEXTURE := preload("res://assets/fruit_icon.png")
const MAX_CARGO_SLOTS := 8
const CARGO_SCALE := 0.5
const CARGO_POSITIONS: Array[Vector2] = [
	Vector2(-32, -28),
	Vector2(0, -32),
	Vector2(32, -28),
	Vector2(-24, -54),
	Vector2(24, -54),
	Vector2(-14, -76),
	Vector2(14, -76),
	Vector2(0, -95),
]

@onready var boat_hull: Sprite2D = $BoatHull
@onready var cargo: Node2D = $Cargo
@onready var camera: Camera2D = $Camera2D
@onready var wake: CPUParticles2D = $Wake

var cargo_sprites: Array[Sprite2D] = []
var external_force := Vector2.ZERO
var _shake_remaining := 0.0
var _shake_intensity := 0.0
@onready var _st: Node = get_node("/root/SceneTransition")
var throttle_amount := 0.0
var wake_strength := 0.0
var visual_roll := 0.0
var visual_bob := 0.0
var water_polygons: Array[PackedVector2Array] = []
var last_safe_position := Vector2.ZERO
var input_blocked := false

func _ready() -> void:
	add_to_group("player")
	wake.emitting = false
	last_safe_position = global_position
	_build_cargo_sprites()

	for spr in cargo_sprites:
		spr.visible = false
		spr.modulate.a = 0.0

	cargo.visible = false

	print("Cargo node visible:", cargo.visible)
	print("Cargo sprites:", cargo_sprites.size())

	queue_redraw()


func _physics_process(delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	var input_vector := Vector2.ZERO
	if not input_blocked:
		input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	throttle_amount = move_toward(throttle_amount, input_vector.length(), delta * 3.8)
	if input_vector.length() > 0.0:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity += external_force
	external_force = external_force.move_toward(Vector2.ZERO, 240.0 * delta)
	move_and_slide()
	if get_slide_collision_count() > 0:
		print("HIT A WALL: ", get_slide_collision(0).get_collider().name)
	global_position.x = clamp(global_position.x, river_bounds.position.x, river_bounds.end.x)
	global_position.y = clamp(global_position.y, river_bounds.position.y, river_bounds.end.y)
	_enforce_water_polygons()
	_resolve_dynamic_obstacles()

	var speed_ratio: float = clamp(velocity.length() / max_speed, 0.0, 1.0)
	wake_strength = move_toward(wake_strength, speed_ratio, delta * 3.2)
	visual_bob += delta * lerpf(1.6, 4.8, wake_strength)
	if velocity.length() > 8.0:
		var target_rotation: float = velocity.angle() + PI / 2.0
		var turn_delta: float = wrapf(target_rotation - rotation, -PI, PI)
		visual_roll = lerpf(visual_roll, clamp(turn_delta * -0.28, -0.18, 0.18), delta * 6.0)
		rotation = lerp_angle(rotation, target_rotation, delta * 7.0)
	else:
		visual_roll = lerpf(visual_roll, 0.0, delta * 4.0)

	_update_visual_motion(delta, speed_ratio)
	queue_redraw()


func shake(duration: float = 0.25, intensity: float = 6.0) -> void:
	_shake_remaining = duration
	_shake_intensity = intensity


func get_wake_strength() -> float:
	return wake_strength


func set_water_polygons(polygons: Array[PackedVector2Array]) -> void:
	water_polygons = polygons
	if _is_boat_inside_water(global_position):
		last_safe_position = global_position


func reset_safe_position(pos: Vector2) -> void:
	global_position = pos
	last_safe_position = pos


func _enforce_water_polygons() -> void:
	if _is_boat_inside_water(global_position):
		last_safe_position = global_position
		return

	var current_position: Vector2 = global_position
	var recovered_position: Vector2 = _find_nearby_water_position(current_position)
	if recovered_position != Vector2.INF:
		global_position = recovered_position
		last_safe_position = global_position
		velocity *= 0.35
		return

	var y_slide := Vector2(last_safe_position.x, current_position.y)
	if _is_boat_inside_water(y_slide):
		global_position = y_slide
		last_safe_position = global_position
		velocity.x = 0.0
		return

	var x_slide := Vector2(current_position.x, last_safe_position.y)
	if _is_boat_inside_water(x_slide):
		global_position = x_slide
		last_safe_position = global_position
		velocity.y = 0.0
		return

	global_position = last_safe_position
	velocity *= 0.18
	external_force = Vector2.ZERO


func _find_nearby_water_position(origin: Vector2) -> Vector2:
	for radius in [10.0, 22.0, 36.0, 54.0, 76.0]:
		for i in range(16):
			var angle: float = TAU * float(i) / 16.0
			var candidate: Vector2 = origin + Vector2(cos(angle), sin(angle)) * radius
			candidate.x = clamp(candidate.x, river_bounds.position.x, river_bounds.end.x)
			candidate.y = clamp(candidate.y, river_bounds.position.y, river_bounds.end.y)
			if _is_boat_inside_water(candidate):
				return candidate
	return Vector2.INF


func _is_boat_inside_water(pos: Vector2) -> bool:
	if not river_bounds.has_point(pos):
		return false
	var samples: Array[Vector2] = [
		Vector2.ZERO,
		Vector2(0.0, -34.0),
		Vector2(0.0, 34.0),
		Vector2(-18.0, 0.0),
		Vector2(18.0, 0.0)
	]
	for sample in samples:
		if not _is_point_inside_water(pos + sample.rotated(rotation)):
			return false
	return true


func _is_point_inside_water(point: Vector2) -> bool:
	if water_polygons.is_empty():
		return river_bounds.has_point(point)
	for polygon in water_polygons:
		if Geometry2D.is_point_in_polygon(point, polygon):
			return true
	return false


func _resolve_dynamic_obstacles() -> void:
	var obstacle_groups: Array[String] = ["merchant_boat", "quest_hub"]
	for group in obstacle_groups:
		for obstacle in get_tree().get_nodes_in_group(group):
			if not obstacle is Node2D or not (obstacle as Node2D).visible:
				continue
			var center: Vector2 = (obstacle as Node2D).global_position
			if obstacle.has_method("get_blocking_center"):
				center = obstacle.call("get_blocking_center") as Vector2
			var radius: float = 112.0
			if obstacle.has_method("get_blocking_radius"):
				radius = float(obstacle.call("get_blocking_radius"))
			var delta: Vector2 = global_position - center
			var distance: float = delta.length()
			if distance <= 0.001 or distance >= radius:
				continue
			var push_dir: Vector2 = delta / distance
			var target_position: Vector2 = center + push_dir * radius
			if _is_boat_inside_water(target_position):
				global_position = target_position
				last_safe_position = global_position
				velocity = velocity.slide(push_dir)
			else:
				velocity *= 0.35


func _update_visual_motion(delta: float, speed_ratio: float) -> void:
	var bob: float = sin(visual_bob) * lerpf(1.2, 4.2, wake_strength)
	var surge: float = sin(visual_bob * 1.6) * 1.6 * throttle_amount
	boat_hull.position = Vector2(0.0, bob - surge)
	boat_hull.rotation = visual_roll + sin(visual_bob * 0.72) * 0.018
	boat_hull.scale = Vector2.ONE * (1.0 + sin(visual_bob * 1.25) * 0.01 * (0.3 + wake_strength))

	var shake_offset := Vector2.ZERO
	if _shake_remaining > 0.0:
		_shake_remaining -= delta
		var decay := clampf(_shake_remaining / 0.25, 0.0, 1.0)
		shake_offset = Vector2(
			randf_range(-_shake_intensity, _shake_intensity) * decay,
			randf_range(-_shake_intensity, _shake_intensity) * decay
		)
	camera.offset = camera.offset.lerp(velocity * 0.10 + shake_offset, delta * 2.2)
	wake.position = Vector2(0, 82 + speed_ratio * 18.0)
	wake.emitting = wake_strength > 0.05
	wake.amount = int(lerpf(20.0, 80.0, wake_strength))
	wake.spread = lerpf(30.0, 65.0, wake_strength)
	wake.initial_velocity_min = lerpf(12.0, 42.0, wake_strength)
	wake.initial_velocity_max = lerpf(32.0, 100.0, wake_strength)
	wake.scale_amount_min = lerpf(1.6, 3.2, wake_strength)
	wake.scale_amount_max = lerpf(3.6, 10.0, wake_strength)


func _draw() -> void:
	var shadow_alpha: float = 0.24 + wake_strength * 0.08
	_draw_ellipse(Vector2(0, 28), Vector2(46, 96), Color(0.0, 0.0, 0.0, shadow_alpha))


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var angle: float = TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func _build_cargo_sprites() -> void:
	for i in range(MAX_CARGO_SLOTS):
		var spr := Sprite2D.new()
		spr.texture = CARGO_TEXTURE
		spr.position = CARGO_POSITIONS[i]
		spr.scale = Vector2(CARGO_SCALE, CARGO_SCALE)
		spr.visible = false
		spr.modulate.a = 0.0
		spr.z_index = 5
		cargo.add_child(spr)
		cargo_sprites.append(spr)


func sync_cargo_visuals(cargo: Dictionary) -> void:
	var total := 0
	for key in cargo.keys():
		total += int(cargo[key])
	total = mini(total, MAX_CARGO_SLOTS)
	for i in range(MAX_CARGO_SLOTS):
		cargo_sprites[i].visible = i < total
		cargo_sprites[i].scale = Vector2(CARGO_SCALE, CARGO_SCALE)


func animate_cargo_load(cargo: Dictionary, product_name: String) -> void:
	var prev_visible := 0
	for spr in cargo_sprites:
		if spr.visible:
			prev_visible += 1

	sync_cargo_visuals(cargo)
	set_has_cargo(true)

	var new_sprites: Array[Sprite2D] = []
	for i in range(prev_visible, MAX_CARGO_SLOTS):
		if cargo_sprites[i].visible:
			new_sprites.append(cargo_sprites[i])

	for spr in new_sprites:
		spr.scale = Vector2.ZERO
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(spr, "scale", Vector2(CARGO_SCALE, CARGO_SCALE), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(spr, "modulate:a", 1.0, 0.35)

	_st.call("play_load_sfx")
	_show_floating_text("+1 " + product_name, Color(0.38, 1.0, 0.55))


func animate_cargo_unload(cargo: Dictionary, products: Dictionary) -> void:
	var has_visible := false
	for spr in cargo_sprites:
		if spr.visible:
			has_visible = true
			break

	if not has_visible:
		sync_cargo_visuals(cargo)
		return

	for spr in cargo_sprites:
		if spr.visible:
			var tween := create_tween()
			tween.set_parallel(true)
			tween.tween_property(spr, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_property(spr, "modulate:a", 0.0, 0.2)

	_st.call("play_unload_sfx")

	var parts: PackedStringArray = PackedStringArray()
	for key in products.keys():
		parts.append("%s x%s" % [str(key), str(products[key])])
	_show_floating_text("Đã giao: " + ", ".join(parts), Color(1.0, 0.82, 0.38))

	await get_tree().create_timer(0.35).timeout
	sync_cargo_visuals(cargo)
	for spr in cargo_sprites:
		spr.modulate.a = 1.0

	if cargo.is_empty():
		set_has_cargo(false)


func _show_floating_text(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	label.add_theme_constant_override("outline_size", 5)
	label.z_index = 20
	label.position = Vector2(-80, -130)
	boat_hull.add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 42, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.9).set_delay(0.15)
	tween.finished.connect(label.queue_free)


func set_has_cargo(state: bool) -> void:
	if not cargo:
		return

	cargo.visible = state

	for spr in cargo_sprites:
		spr.visible = state
		spr.modulate.a = 1.0 if state else 0.0


func spawn_particles(color: Color, count: int = 8) -> void:
	for i in range(count):
		var p := ColorRect.new()
		p.size = Vector2(5, 5)
		p.color = color
		var offset := Vector2(randf_range(-40, 40), randf_range(-60, 20))
		p.position = offset - Vector2(2.5, 2.5)
		boat_hull.add_child(p)
		var angle := TAU * float(i) / float(count) + randf_range(-0.2, 0.2)
		var dist := randf_range(40, 90)
		var target := Vector2(cos(angle), sin(angle)) * dist
		var ptween := create_tween()
		ptween.set_parallel(true)
		ptween.tween_property(p, "position", offset + target, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		ptween.tween_property(p, "modulate:a", 0.0, 0.5)
		ptween.finished.connect(p.queue_free)
