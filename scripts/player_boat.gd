extends CharacterBody2D

@export var max_speed := 240.0
@export var acceleration := 720.0
@export var friction := 560.0
@export var river_bounds := Rect2(160, 120, 1600, 820)

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var wake: CPUParticles2D = $Wake
var external_force := Vector2.ZERO
var throttle_amount := 0.0
var wake_strength := 0.0
var visual_roll := 0.0
var visual_bob := 0.0
var water_polygons: Array[PackedVector2Array] = []
var last_safe_position := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	wake.emitting = false
	last_safe_position = global_position
	queue_redraw()


func _physics_process(delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	throttle_amount = move_toward(throttle_amount, input_vector.length(), delta * 3.8)
	if input_vector.length() > 0.0:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity += external_force
	external_force = external_force.move_toward(Vector2.ZERO, 240.0 * delta)
	move_and_slide()
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
		visual_roll = lerpf(visual_roll, clamp(turn_delta * -0.22, -0.12, 0.12), delta * 5.5)
		rotation = lerp_angle(rotation, target_rotation, delta * 7.0)
	else:
		visual_roll = lerpf(visual_roll, 0.0, delta * 4.0)

	_update_visual_motion(delta, speed_ratio)
	queue_redraw()


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
	sprite.position = Vector2(0.0, bob - surge)
	sprite.rotation = visual_roll + sin(visual_bob * 0.72) * 0.018
	sprite.scale = Vector2.ONE * (1.0 + sin(visual_bob * 1.25) * 0.01 * (0.3 + wake_strength))

	camera.offset = camera.offset.lerp(velocity * 0.10, delta * 2.2)
	wake.position = Vector2(0, 82 + speed_ratio * 18.0)
	wake.emitting = wake_strength > 0.05
	wake.amount = int(lerpf(16.0, 58.0, wake_strength))
	wake.spread = lerpf(26.0, 54.0, wake_strength)
	wake.initial_velocity_min = lerpf(10.0, 36.0, wake_strength)
	wake.initial_velocity_max = lerpf(28.0, 82.0, wake_strength)
	wake.scale_amount_min = lerpf(1.4, 2.4, wake_strength)
	wake.scale_amount_max = lerpf(3.0, 7.2, wake_strength)


func _draw() -> void:
	var shadow_alpha: float = 0.24 + wake_strength * 0.08
	_draw_ellipse(Vector2(0, 28), Vector2(46, 96), Color(0.0, 0.0, 0.0, shadow_alpha))


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var angle: float = TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
