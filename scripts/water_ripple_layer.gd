extends Node2D

const WAVE_LANE_COUNT: int = 68
const POINTS_PER_WAVE: int = 48

var world_size: Vector2 = Vector2(3072, 1728)
var waves: Array[Dictionary] = []

func _ready() -> void:
	z_index = -10
	_generate_waves()


func set_world_size(size: Vector2) -> void:
	world_size = size
	_generate_waves()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	for wave in waves:
		_draw_water_wave(wave, t)


func _draw_water_wave(wave: Dictionary, t: float) -> void:
	var base_y: float = float(wave["y"])
	var start_x: float = float(wave["start_x"])
	var length: float = float(wave["length"])
	var amplitude: float = float(wave["amplitude"])
	var frequency: float = float(wave["frequency"])
	var drift: float = float(wave["drift"])
	var phase: float = float(wave["phase"]) + t * drift
	var alpha: float = float(wave["alpha"]) * (0.76 + sin(t * 0.9 + phase) * 0.18)
	var width: float = float(wave["width"])
	var color: Color = Color(0.78, 0.94, 1.0, alpha)

	var points := PackedVector2Array()
	for i in range(POINTS_PER_WAVE):
		var ratio: float = float(i) / float(POINTS_PER_WAVE - 1)
		var x: float = start_x + length * ratio
		var taper: float = sin(ratio * PI)
		var y: float = base_y + sin((ratio * frequency + phase) * TAU) * amplitude * taper
		points.append(Vector2(x, y))

	draw_polyline(points, color, width, true)

	# A second line makes this read as a river-surface ripple, not a floating light.
	if bool(wave["highlight"]):
		var highlight_points := PackedVector2Array()
		for i in range(POINTS_PER_WAVE):
			var ratio: float = float(i) / float(POINTS_PER_WAVE - 1)
			var x: float = start_x + length * (ratio * 0.55 + 0.18)
			var taper: float = sin(ratio * PI)
			var y: float = base_y + 7.0 + cos((ratio * frequency + phase * 1.2) * TAU) * amplitude * 0.45 * taper
			highlight_points.append(Vector2(x, y))
		draw_polyline(highlight_points, Color(0.58, 0.9, 1.0, alpha * 0.45), max(1.0, width * 0.55), true)


func _generate_waves() -> void:
	waves.clear()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7391

	var river_left: float = world_size.x * 0.18
	var river_right: float = world_size.x * 0.82
	var river_top: float = world_size.y * 0.15
	var river_bottom: float = world_size.y * 0.90
	var river_width: float = river_right - river_left

	for i in range(WAVE_LANE_COUNT):
		var y_ratio: float = float(i) / float(WAVE_LANE_COUNT - 1)
		var y: float = lerpf(river_top, river_bottom, y_ratio) + rng.randf_range(-18.0, 18.0)
		var center_bias: float = sin(y_ratio * PI)
		var max_length: float = lerpf(river_width * 0.55, river_width * 0.92, center_bias)
		var length: float = rng.randf_range(max_length * 0.62, max_length)
		var start_x: float = rng.randf_range(river_left, river_right - length)

		waves.append({
			"y": y,
			"start_x": start_x,
			"length": length,
			"amplitude": rng.randf_range(3.0, 10.0),
			"frequency": rng.randf_range(1.4, 4.0),
			"drift": rng.randf_range(0.12, 0.30),
			"phase": rng.randf(),
			"alpha": rng.randf_range(0.20, 0.42),
			"width": rng.randf_range(1.4, 3.0),
			"highlight": rng.randf() > 0.35
		})
