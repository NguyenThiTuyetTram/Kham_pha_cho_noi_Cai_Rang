extends Node2D

const SURFACE_STREAK_COUNT: int = 210
const MICRO_RIPPLE_COUNT: int = 42
const STREAK_POINTS: int = 8
const WAKE_POINTS: int = 24

var world_size: Vector2 = Vector2(3072, 1728)
var river_rect: Rect2 = Rect2(Vector2(460, 260), Vector2(2150, 1350))
var flow_vector: Vector2 = Vector2(1.0, -0.16)
var flow_speed: float = 1.0
var chop: float = 1.0
var density: float = 1.0
var water_tint: Color = Color(0.54, 0.76, 0.82, 0.20)
var foam_tint: Color = Color(0.82, 0.93, 0.92, 0.24)
var shadow_tint: Color = Color(0.04, 0.15, 0.16, 0.18)

var surface_streaks: Array[Dictionary] = []
var micro_ripples: Array[Dictionary] = []
var current_fields: Array[Dictionary] = []
var surface_noise: FastNoiseLite = FastNoiseLite.new()
var player: Node2D


func _ready() -> void:
	z_index = -10
	surface_noise.seed = 18473
	surface_noise.frequency = 0.0048
	surface_noise.fractal_octaves = 4
	surface_noise.fractal_gain = 0.44
	_generate_surface()


func set_world_size(size: Vector2) -> void:
	world_size = size
	river_rect = Rect2(world_size * Vector2(0.15, 0.11), world_size * Vector2(0.70, 0.78))
	_generate_surface()


func configure_for_map(style: Dictionary) -> void:
	flow_vector = (style.get("flow", Vector2(1.0, -0.16)) as Vector2).normalized()
	if flow_vector == Vector2.ZERO:
		flow_vector = Vector2.RIGHT
	flow_speed = float(style.get("speed", 1.0))
	chop = float(style.get("chop", 1.0))
	density = float(style.get("density", 1.0))
	water_tint = style.get("water_tint", water_tint) as Color
	foam_tint = style.get("foam_tint", foam_tint) as Color
	shadow_tint = style.get("shadow_tint", shadow_tint) as Color
	_generate_surface()


func set_current_fields(configs: Array, world_scale: float) -> void:
	current_fields.clear()
	for data in configs:
		var config: Dictionary = data as Dictionary
		current_fields.append({
			"pos": (config.get("pos", Vector2.ZERO) as Vector2) * world_scale,
			"force": config.get("force", Vector2.ZERO) as Vector2,
			"phase": float(current_fields.size()) * 1.7
		})


func _process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	queue_redraw()


func _draw() -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	_draw_surface_streaks(t)
	_draw_micro_ripples(t)
	_draw_current_detail(t)
	_draw_static_contact_water(t)
	_draw_player_wake(t)


func _draw_surface_streaks(t: float) -> void:
	var normal: Vector2 = Vector2(-flow_vector.y, flow_vector.x)
	for streak in surface_streaks:
		var base: Vector2 = streak["pos"] as Vector2
		var cycle: float = float(streak["cycle"])
		var age: float = fmod(t * float(streak["speed"]) + float(streak["phase"]), cycle) / cycle
		var pos: Vector2 = _wrap_in_river(base + flow_vector * age * float(streak["travel"]))
		var length: float = float(streak["length"])
		var width: float = float(streak["width"])
		var bend: float = float(streak["bend"]) * chop
		var fade: float = sin(age * PI)
		var noise_alpha: float = 0.72 + surface_noise.get_noise_2d(pos.x * 0.28, pos.y * 0.28 + t * 8.0) * 0.28
		var color: Color = foam_tint.lerp(water_tint, float(streak["tint_mix"]))
		color.a *= float(streak["alpha"]) * fade * noise_alpha
		if color.a < 0.008:
			continue

		var points := PackedVector2Array()
		for i in range(STREAK_POINTS):
			var ratio: float = float(i) / float(STREAK_POINTS - 1)
			var centered: float = ratio - 0.5
			var jitter: float = surface_noise.get_noise_2d(pos.x + ratio * 120.0, pos.y + t * 18.0)
			var along: Vector2 = flow_vector * centered * length
			var sideways: Vector2 = normal * (sin(ratio * PI * 1.4 + float(streak["phase"])) * bend + jitter * bend * 0.6)
			points.append(pos + along + sideways)
		_draw_broken_polyline(points, color, width, float(streak["phase"]) + t * 0.22)


func _draw_micro_ripples(t: float) -> void:
	for ripple in micro_ripples:
		var cycle: float = float(ripple["cycle"])
		var age: float = fmod(t * float(ripple["speed"]) + float(ripple["phase"]), cycle) / cycle
		var center: Vector2 = _wrap_in_river((ripple["pos"] as Vector2) + flow_vector * age * float(ripple["travel"]))
		var fade: float = sin(age * PI)
		var radius: Vector2 = (ripple["radius"] as Vector2) * lerpf(0.55, 1.18, age)
		var color: Color = water_tint
		color.a *= float(ripple["alpha"]) * fade
		var angle: float = float(ripple["angle"]) + age * 0.18
		_draw_partial_ellipse(center, radius, angle, float(ripple["start"]), float(ripple["span"]), color, float(ripple["width"]), 15)


func _draw_current_detail(t: float) -> void:
	for field in current_fields:
		var force: Vector2 = field["force"] as Vector2
		if force.length() < 1.0:
			continue
		var center: Vector2 = field["pos"] as Vector2
		var dir: Vector2 = force.normalized()
		var normal: Vector2 = Vector2(-dir.y, dir.x)
		for i in range(7):
			var lane: float = float(i - 3)
			var phase: float = fmod(t * (0.20 + i * 0.018) + float(field["phase"]) + i * 0.23, 1.0)
			var pos: Vector2 = center + dir * lerpf(-145.0, 150.0, phase) + normal * lane * 24.0
			var color: Color = foam_tint
			color.a *= sin(phase * PI) * 0.105
			var length: float = lerpf(42.0, 86.0, abs(lane) / 3.0)
			var points := PackedVector2Array()
			for p in range(7):
				var r: float = float(p) / 6.0
				var hook: float = sin(r * PI) * (10.0 + abs(lane) * 2.0)
				points.append(pos + dir * (r - 0.5) * length + normal * hook * sign(lane + 0.1))
			_draw_broken_polyline(points, color, 1.35, phase)


func _draw_static_contact_water(t: float) -> void:
	var groups: Array[Dictionary] = [
		{"name": "merchant_boat", "length": 118.0, "alpha": 0.115, "count": 4},
		{"name": "quest_hub", "length": 132.0, "alpha": 0.10, "count": 4},
		{"name": "delivery_point", "length": 74.0, "alpha": 0.055, "count": 2},
		{"name": "scenic_spot", "length": 64.0, "alpha": 0.045, "count": 2},
		{"name": "river_portal", "length": 88.0, "alpha": 0.055, "count": 3}
	]
	var normal: Vector2 = Vector2(-flow_vector.y, flow_vector.x)
	for group in groups:
		for node in get_tree().get_nodes_in_group(str(group["name"])):
			if not node is Node2D or not (node as Node2D).visible:
				continue
			var pos: Vector2 = (node as Node2D).global_position
			if not river_rect.grow(180.0).has_point(pos):
				continue
			var seed: float = pos.x * 0.013 + pos.y * 0.017
			for i in range(int(group["count"])):
				var phase: float = fmod(t * (0.16 + i * 0.025) + seed + i * 0.21, 1.0)
				var side: float = -1.0 if i % 2 == 0 else 1.0
				var origin: Vector2 = pos - flow_vector * 24.0 + normal * side * (22.0 + i * 13.0)
				var length: float = float(group["length"]) * lerpf(0.55, 1.0, phase)
				var color: Color = water_tint
				color.a *= float(group["alpha"]) * sin(phase * PI)
				var points := PackedVector2Array()
				for p in range(7):
					var r: float = float(p) / 6.0
					var noise: float = surface_noise.get_noise_2d(origin.x + p * 18.0, origin.y + t * 10.0)
					points.append(origin + flow_vector * (r - 0.5) * length + normal * noise * 7.0)
				_draw_broken_polyline(points, color, 1.15, phase + seed)


func _draw_player_wake(t: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	var velocity_value: Variant = player.get("velocity")
	if not velocity_value is Vector2:
		return
	var velocity: Vector2 = velocity_value as Vector2
	var speed: float = velocity.length()
	if speed < 20.0:
		return

	var dir: Vector2 = velocity.normalized()
	var normal: Vector2 = Vector2(-dir.y, dir.x)
	var origin: Vector2 = player.global_position - dir * 42.0
	var strength: float = clamp(speed / 270.0, 0.0, 1.0)

	for side in [-1.0, 1.0]:
		for band in range(3):
			var points := PackedVector2Array()
			var band_offset: float = float(band) * 22.0
			for i in range(WAKE_POINTS):
				var ratio: float = float(i) / float(WAKE_POINTS - 1)
				var back: float = ratio * lerpf(105.0, 230.0, strength) + band_offset
				var spread: float = pow(ratio, 0.78) * lerpf(34.0, 118.0, strength) + band * 8.0
				var noise: float = surface_noise.get_noise_2d(origin.x + i * 19.0, origin.y + t * 24.0 + band * 31.0)
				points.append(origin - dir * back + normal * side * (spread + noise * 8.0 * strength))
			var color: Color = foam_tint
			color.a *= strength * (0.18 - band * 0.04)
			_draw_broken_polyline(points, color, 1.7 - band * 0.25, t * 0.18 + band)

	for i in range(8):
		var phase: float = fmod(t * 0.55 + i * 0.137, 1.0)
		var pos: Vector2 = origin - dir * lerpf(8.0, 88.0, phase) + normal * sin(i * 1.7 + t) * 10.0
		var color: Color = foam_tint
		color.a *= strength * sin(phase * PI) * 0.13
		draw_circle(pos, lerpf(1.3, 3.4, phase), color)


func _draw_broken_polyline(points: PackedVector2Array, color: Color, width: float, phase: float) -> void:
	for i in range(points.size() - 1):
		var mask: float = surface_noise.get_noise_2d(float(i) * 18.0 + phase * 100.0, phase * 41.0)
		if mask < -0.34:
			continue
		var segment_color: Color = color
		segment_color.a *= lerpf(0.55, 1.0, clamp(mask * 0.5 + 0.5, 0.0, 1.0))
		draw_line(points[i], points[i + 1], segment_color, width, true)


func _draw_partial_ellipse(center: Vector2, radius: Vector2, rotation_angle: float, start_angle: float, span: float, color: Color, width: float, steps: int) -> void:
	var points := PackedVector2Array()
	for i in range(steps):
		var ratio: float = float(i) / float(steps - 1)
		var a: float = start_angle + span * ratio
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y).rotated(rotation_angle))
	_draw_broken_polyline(points, color, width, start_angle + span)


func _wrap_in_river(pos: Vector2) -> Vector2:
	var wrapped: Vector2 = pos
	if wrapped.x < river_rect.position.x:
		wrapped.x += river_rect.size.x
	elif wrapped.x > river_rect.end.x:
		wrapped.x -= river_rect.size.x
	if wrapped.y < river_rect.position.y:
		wrapped.y += river_rect.size.y
	elif wrapped.y > river_rect.end.y:
		wrapped.y -= river_rect.size.y
	return wrapped


func _generate_surface() -> void:
	surface_streaks.clear()
	micro_ripples.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7391

	var streak_count: int = max(70, int(SURFACE_STREAK_COUNT * density))
	for _i in range(streak_count):
		var y_ratio: float = rng.randf()
		var center_bias: float = sin(y_ratio * PI)
		var margin: float = lerpf(river_rect.size.x * 0.24, river_rect.size.x * 0.05, center_bias)
		surface_streaks.append({
			"pos": Vector2(rng.randf_range(river_rect.position.x + margin, river_rect.end.x - margin), lerpf(river_rect.position.y, river_rect.end.y, y_ratio)),
			"length": rng.randf_range(44.0, 170.0) * lerpf(0.72, 1.25, center_bias),
			"width": rng.randf_range(0.65, 1.55),
			"alpha": rng.randf_range(0.018, 0.072),
			"phase": rng.randf_range(0.0, 8.0),
			"cycle": rng.randf_range(3.6, 8.8),
			"speed": rng.randf_range(0.35, 0.86) * flow_speed,
			"travel": rng.randf_range(95.0, 260.0),
			"bend": rng.randf_range(2.0, 9.0),
			"tint_mix": rng.randf_range(0.1, 0.65)
		})

	var ripple_count: int = max(12, int(MICRO_RIPPLE_COUNT * density))
	for _i in range(ripple_count):
		var y_ratio: float = rng.randf()
		var center_bias: float = sin(y_ratio * PI)
		var margin: float = lerpf(river_rect.size.x * 0.28, river_rect.size.x * 0.08, center_bias)
		micro_ripples.append({
			"pos": Vector2(rng.randf_range(river_rect.position.x + margin, river_rect.end.x - margin), lerpf(river_rect.position.y, river_rect.end.y, y_ratio)),
			"radius": Vector2(rng.randf_range(18.0, 54.0), rng.randf_range(4.0, 12.0)),
			"angle": rng.randf_range(-PI, PI),
			"start": rng.randf_range(-PI, PI),
			"span": rng.randf_range(PI * 0.34, PI * 0.82),
			"phase": rng.randf_range(0.0, 8.0),
			"cycle": rng.randf_range(4.8, 10.0),
			"speed": rng.randf_range(0.22, 0.54) * flow_speed,
			"travel": rng.randf_range(30.0, 110.0),
			"alpha": rng.randf_range(0.028, 0.074),
			"width": rng.randf_range(0.75, 1.15)
		})
