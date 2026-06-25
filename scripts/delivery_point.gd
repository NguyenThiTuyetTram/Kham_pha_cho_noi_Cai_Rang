extends Area2D

@export var point_name := "Tiệm Ánh Đèn"

var player_near := false
var name_label: Label
@onready var marker: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_create_nameplate()
	_update_nameplate()


func _process(_delta: float) -> void:
	marker.rotation = sin(Time.get_ticks_msec() / 500.0) * 0.05
	marker.scale = Vector2.ONE * (1.0 + sin(Time.get_ticks_msec() / 220.0) * 0.04)
	_update_nameplate()


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact"):
		get_tree().current_scene.complete_delivery(self)
		_update_prompt()
		get_viewport().set_input_as_handled()


func delivery_feedback() -> void:
	var tween := create_tween()
	tween.tween_property(marker, "modulate", Color(1.0, 0.92, 0.35, 1.0), 0.12)
	tween.tween_property(marker, "modulate", Color.WHITE, 0.35)


func _update_prompt() -> void:
	if not player_near:
		return
	if get_tree().current_scene.get_current_delivery_name() == point_name:
		if get_tree().current_scene.can_deliver_at(point_name):
			get_tree().current_scene.show_prompt("E giao hàng tại %s" % point_name)
		else:
			get_tree().current_scene.show_prompt("%s cần đúng hàng trong nhiệm vụ" % point_name)
	else:
		get_tree().current_scene.show_prompt("%s chưa nhận đơn hiện tại" % point_name)


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = Vector2(-130, -105)
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


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		_update_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()
