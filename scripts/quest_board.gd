extends Area2D

@export var board_id := "cai_rang_dispatch"
@export var board_name := "Trạm Điều Phối Cái Răng"
@export var board_role := "Nhận hợp đồng"

var player_near := false
var name_label: Label
@onready var marker: Sprite2D = $Sprite2D
@onready var quest_boat: Sprite2D = $QuestBoat
@onready var npc: Sprite2D = $NPC

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker.modulate = Color(1.0, 0.72, 0.22, 1.0)
	_create_nameplate()
	_update_nameplate()


func _process(_delta: float) -> void:
	marker.scale = Vector2.ONE * (0.95 + sin(Time.get_ticks_msec() / 260.0) * 0.05)
	quest_boat.position.y = sin(Time.get_ticks_msec() / 430.0) * 2.5
	npc.position.y = -38.0 + sin(Time.get_ticks_msec() / 530.0) * 1.8


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact"):
		get_tree().current_scene.accept_quest(self)
		get_viewport().set_input_as_handled()


func setup(id: String, label: String, role: String) -> void:
	board_id = id
	board_name = label
	board_role = role
	_update_nameplate()


func accept_feedback() -> void:
	var tween := create_tween()
	tween.tween_property(marker, "modulate", Color(0.4, 1.0, 0.82, 1.0), 0.15)
	tween.tween_property(marker, "modulate", Color(1.0, 0.72, 0.22, 1.0), 0.3)


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = Vector2(-170, -170)
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


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		get_tree().current_scene.show_prompt("E nhận nhiệm vụ tại %s" % board_name)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()
