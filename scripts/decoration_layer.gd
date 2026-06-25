extends Node2D

var decorations: Array[Dictionary] = []
var world_scale: float = 1.6

func _ready() -> void:
	z_index = 4


func set_decorations(items: Array, scale_factor: float) -> void:
	decorations.clear()
	world_scale = scale_factor
	for item in items:
		decorations.append(item as Dictionary)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	for item in decorations:
		var kind: String = str(item.get("kind", "lantern"))
		var pos: Vector2 = (item["pos"] as Vector2) * world_scale
		match kind:
			"lantern":
				_draw_lantern(pos, t + float(item.get("phase", 0.0)))
			"sign":
				_draw_neon_sign(pos, str(item.get("label", "PRU213")), t)


func _draw_lantern(pos: Vector2, t: float) -> void:
	var bob: float = sin(t * 2.0) * 4.0
	var p: Vector2 = pos + Vector2(0, bob)
	var body: PackedVector2Array = PackedVector2Array([
		p + Vector2(0, -16),
		p + Vector2(13, 0),
		p + Vector2(0, 16),
		p + Vector2(-13, 0)
	])
	var outline: PackedVector2Array = PackedVector2Array([
		body[0],
		body[1],
		body[2],
		body[3],
		body[0]
	])
	draw_polygon(body, PackedColorArray([
		Color(1.0, 0.55, 0.16, 0.78),
		Color(1.0, 0.55, 0.16, 0.78),
		Color(1.0, 0.55, 0.16, 0.78),
		Color(1.0, 0.55, 0.16, 0.78)
	]))
	draw_line(p + Vector2(0, -25), p + Vector2(0, -52), Color(0.08, 0.04, 0.02, 0.7), 3.0)
	draw_polyline(outline, Color(1.0, 0.9, 0.45, 0.8), 2.0, true)


func _draw_neon_sign(pos: Vector2, label: String, t: float) -> void:
	var pulse: float = 0.55 + sin(t * 3.0) * 0.12
	var rect: Rect2 = Rect2(pos - Vector2(82, 22), Vector2(164, 44))
	draw_rect(rect, Color(0.02, 0.04, 0.08, 0.78), true)
	draw_rect(rect, Color(1.0, 0.28, 0.78, pulse), false, 3.0)
	draw_string(ThemeDB.fallback_font, pos + Vector2(-54, 7), label, HORIZONTAL_ALIGNMENT_LEFT, 120, 18, Color(0.75, 1.0, 1.0, 0.95))
