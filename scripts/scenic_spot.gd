extends Area2D

@export var spot_id := "lantern_bridge"
@export var spot_name := "Cầu Đèn Lồng"

var player_near := false
var name_label: Label
@onready var marker: Sprite2D = $Sprite2D
var shimmer_phase := 0.0

func _ready() -> void:
	add_to_group("scenic_spot")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker.modulate = Color(0.35, 1.0, 1.0, 0.95)
	_create_nameplate()
	_update_nameplate()


func _process(delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	shimmer_phase += delta
	var attention: float = 1.0 if player_near else 0.0
	marker.scale = Vector2.ONE * (0.78 + attention * 0.09 + sin(shimmer_phase * 4.8) * 0.055)
	marker.rotation = sin(shimmer_phase * 1.6) * 0.08
	_update_nameplate()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact") and get_tree().current_scene.is_nearest_interactable(self):
		get_tree().current_scene.discover_spot(self)
		get_viewport().set_input_as_handled()


func discovery_feedback() -> void:
	var tween := create_tween()
	tween.tween_property(marker, "modulate", Color(1.0, 0.85, 0.25, 1.0), 0.15)
	tween.tween_property(marker, "modulate", Color(0.35, 1.0, 1.0, 0.95), 0.35)


func reset_interaction_state() -> void:
	player_near = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		get_tree().current_scene.show_prompt("E chụp ảnh tại %s" % spot_name)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = Vector2(-130, -100)
	name_label.size = Vector2(260, 46)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.48, 0.96, 1.0))
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(name_label)


func _update_nameplate() -> void:
	if name_label == null:
		return
	name_label.text = "Check-in\n%s" % spot_name
	name_label.modulate.a = 1.0 if player_near else 0.76


func _draw() -> void:
	if player_near:
		draw_circle(Vector2.ZERO, 34.0, Color(0.42, 0.96, 1.0, 0.045))
