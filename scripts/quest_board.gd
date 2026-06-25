extends Area2D

@export var board_id := "cai_rang_dispatch"
@export var board_name := "Trạm Điều Phối Cái Răng"
@export var board_role := "Nhận hợp đồng"

var player_near := false
var name_label: Label
@onready var marker: Sprite2D = $Sprite2D
@onready var quest_boat: Sprite2D = $QuestBoat
@onready var npc: Sprite2D = $NPC
var bob_phase := 0.0
var marker_base_position := Vector2(76, -72)
var npc_base_position := Vector2(-58, -38)
var boat_base_position := Vector2.ZERO
var nameplate_base_position := Vector2(-170, -170)

func _ready() -> void:
	add_to_group("quest_hub")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker_base_position = marker.position
	npc_base_position = npc.position
	boat_base_position = quest_boat.position
	marker.modulate = Color(1.0, 0.72, 0.22, 1.0)
	_create_nameplate()
	_update_nameplate()


func _process(delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	bob_phase += delta
	var attention: float = 1.0 if player_near else 0.0
	marker.position = marker_base_position + Vector2(0.0, sin(bob_phase * 2.9) * 2.0)
	marker.scale = Vector2.ONE * (0.88 + attention * 0.08 + sin(bob_phase * 4.1) * 0.045)
	marker.rotation = sin(bob_phase * 2.7) * 0.05
	quest_boat.position = boat_base_position + Vector2(0.0, sin(bob_phase * 2.1) * 3.2)
	quest_boat.rotation = sin(bob_phase * 1.35) * 0.025
	npc.position = npc_base_position + Vector2(0.0, sin(bob_phase * 1.7) * 2.0)
	npc.rotation = sin(bob_phase * 1.2) * 0.018
	_update_nameplate()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact") and get_tree().current_scene.is_nearest_interactable(self):
		get_tree().current_scene.accept_quest(self)
		get_viewport().set_input_as_handled()


func setup(id: String, label: String, role: String, visuals: Dictionary = {}) -> void:
	board_id = id
	board_name = label
	board_role = role
	setup_visuals(
		visuals.get("marker_offset", marker_base_position) as Vector2,
		visuals.get("npc_offset", npc_base_position) as Vector2,
		visuals.get("boat_offset", boat_base_position) as Vector2,
		visuals.get("label_offset", nameplate_base_position) as Vector2
	)
	_update_nameplate()


func setup_visuals(marker_offset: Vector2, npc_offset: Vector2, boat_offset: Vector2, label_offset: Vector2) -> void:
	marker_base_position = marker_offset
	npc_base_position = npc_offset
	boat_base_position = boat_offset
	nameplate_base_position = label_offset
	if marker != null:
		marker.position = marker_base_position
	if npc != null:
		npc.position = npc_base_position
	if quest_boat != null:
		quest_boat.position = boat_base_position
	if name_label != null:
		name_label.position = nameplate_base_position


func reset_interaction_state() -> void:
	player_near = false


func accept_feedback() -> void:
	var tween := create_tween()
	tween.tween_property(marker, "modulate", Color(0.4, 1.0, 0.82, 1.0), 0.15)
	tween.tween_property(marker, "modulate", Color(1.0, 0.72, 0.22, 1.0), 0.3)


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = nameplate_base_position
	name_label.size = Vector2(340, 64)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.42))
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(name_label)


func _update_nameplate() -> void:
	if name_label == null:
		return
	name_label.text = "%s\n%s" % [board_name, board_role]
	name_label.modulate.a = 1.0 if player_near else 0.82


func _draw() -> void:
	_draw_ellipse(Vector2(0, 26), Vector2(116, 40), Color(0.0, 0.0, 0.0, 0.24))
	if player_near:
		_draw_ellipse(Vector2(0, 18), Vector2(130, 46), Color(1.0, 0.74, 0.28, 0.06))


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(36):
		var angle: float = TAU * float(i) / 36.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		get_tree().current_scene.show_prompt("E nhận nhiệm vụ tại %s" % board_name)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()
