extends Area2D

@export var current_force := Vector2(38, 0)

var flow_phase := 0.0


func _ready() -> void:
	z_index = -8


func _process(delta: float) -> void:
	flow_phase += delta
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if not monitoring:
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.external_force += current_force * 0.018


func _draw() -> void:
	if current_force.length() < 1.0:
		return
	var dir: Vector2 = current_force.normalized()
	var normal: Vector2 = Vector2(-dir.y, dir.x)
	for i in range(5):
		var lane: float = float(i - 2)
		var progress: float = fmod(flow_phase * (0.28 + i * 0.035) + i * 0.17, 1.0)
		var center: Vector2 = dir * lerpf(-110.0, 110.0, progress) + normal * lane * 26.0
		var alpha: float = sin(progress * PI) * 0.12
		var color := Color(0.72, 0.96, 1.0, alpha)
		draw_line(center - dir * 34.0, center + dir * 34.0, color, 1.55, true)
		draw_line(center + dir * 34.0, center + dir * 18.0 + normal * 8.0, color, 1.2, true)
		draw_line(center + dir * 34.0, center + dir * 18.0 - normal * 8.0, color, 1.2, true)
