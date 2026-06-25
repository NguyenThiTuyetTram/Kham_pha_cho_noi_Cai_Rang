extends Area2D

@export var target_map_id := "cai_rang"
@export var target_spawn := Vector2(960, 760)
@export var portal_name := "Cổng sông"

var player_near := false
var name_label: Label
@onready var marker: Sprite2D = $Sprite2D
var flow_phase := 0.0

func _ready() -> void:
	add_to_group("river_portal")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker.modulate = Color(0.42, 0.92, 1.0, 0.95)
	_create_nameplate()
	_update_nameplate()


func _process(delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	flow_phase += delta
	var attention: float = 1.0 if player_near else 0.0
	marker.scale = Vector2.ONE * (0.84 + attention * 0.10 + sin(flow_phase * 4.0) * 0.045)
	marker.rotation = sin(flow_phase * 1.9) * 0.09
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact") and get_tree().current_scene.is_nearest_interactable(self):
		get_tree().current_scene.change_map(target_map_id, target_spawn)
		get_viewport().set_input_as_handled()


func setup(next_map: String, spawn: Vector2, label: String) -> void:
	target_map_id = next_map
	target_spawn = spawn
	portal_name = label
	_update_nameplate()


func reset_interaction_state() -> void:
	player_near = false


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = Vector2(-130, -100)
	name_label.size = Vector2(260, 44)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.62, 0.92, 1.0))
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(name_label)


func _update_nameplate() -> void:
	if name_label == null:
		return
	name_label.text = "Lối sông\n%s" % portal_name


func _draw() -> void:
	if player_near:
		draw_circle(Vector2.ZERO, 42.0, Color(0.48, 0.92, 1.0, 0.05))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		get_tree().current_scene.show_prompt("E đi đến %s" % portal_name)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()
