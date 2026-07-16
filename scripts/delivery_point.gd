extends Area2D

@export var point_name := "Tiệm Ánh Đèn"

var player_near := false
var name_label: Label
@onready var marker: Sprite2D = $Sprite2D
@onready var npc: Sprite2D = $NPC
var bob_phase := 0.0
var marker_base_position := Vector2.ZERO
var npc_base_position := Vector2(58, 24)
var nameplate_base_position := Vector2(-130, -105)

func _ready() -> void:
	add_to_group("delivery_point")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker_base_position = marker.position
	npc_base_position = npc.position
	_create_nameplate()
	_update_nameplate()
	bob_phase = randf_range(0, TAU)


func _process(delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	bob_phase += delta
	var attention: float = 1.0 if player_near else 0.0
	marker.position = marker_base_position + Vector2(0.0, sin(bob_phase * 2.4) * 2.0)
	marker.rotation = sin(bob_phase * 2.0) * 0.06
	marker.scale = Vector2.ONE * (0.92 + attention * 0.08 + sin(bob_phase * 4.5) * 0.04)
	npc.position = npc_base_position + Vector2(0.0, sin(bob_phase * 1.55) * 1.0)
	npc.rotation = sin(bob_phase * 0.45) * 0.035
	if player_near:
		var p = get_tree().current_scene.player
		if p:
			npc.flip_h = global_position.x > p.global_position.x
	_update_nameplate()
	queue_redraw()


func delivery_feedback() -> void:
	var tween := create_tween()
	tween.tween_property(marker, "modulate", Color(1.0, 0.92, 0.35, 1.0), 0.12)
	tween.tween_property(marker, "modulate", Color.WHITE, 0.35)


func setup_visuals(marker_offset: Vector2, npc_offset: Vector2, label_offset: Vector2) -> void:
	marker_base_position = marker_offset
	npc_base_position = npc_offset
	nameplate_base_position = label_offset
	if marker != null:
		marker.position = marker_base_position
	if npc != null:
		npc.position = npc_base_position
	if name_label != null:
		name_label.position = nameplate_base_position


func reset_interaction_state() -> void:
	player_near = false


func _update_prompt() -> void:
	if not player_near:
		return
	var current_delivery_name := str(get_tree().current_scene.get_current_delivery_name())
	var can_deliver := bool(get_tree().current_scene.can_deliver_at(point_name))
	print("=== DEBUG PROMPT ===")
	print("Point Name: ", point_name, " | Target Delivery: ", current_delivery_name)
	print("Can deliver: ", can_deliver)
	
	if current_delivery_name == point_name:
		if can_deliver:
			get_tree().current_scene.show_prompt("Giữ E giao hàng tại %s" % point_name)
		else:
			get_tree().current_scene.show_prompt("%s cần đúng hàng trong nhiệm vụ" % point_name)
	else:
		get_tree().current_scene.show_prompt("%s chưa nhận đơn hiện tại" % point_name)


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = nameplate_base_position
	name_label.size = Vector2(260, 46)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.62, 1.0, 0.94))
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(name_label)


func _update_nameplate() -> void:
	if name_label == null:
		return
	name_label.text = "Điểm giao\n%s" % point_name


func _draw() -> void:
	_draw_ellipse(Vector2(18, 34), Vector2(82, 28), Color(0.0, 0.0, 0.0, 0.22))
	if player_near:
		_draw_ellipse(Vector2(10, 24), Vector2(92, 32), Color(0.54, 1.0, 0.86, 0.055))


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(34):
		var angle: float = TAU * float(i) / 34.0
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


