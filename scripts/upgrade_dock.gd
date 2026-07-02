extends Area2D

var player_near := false
@onready var marker: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("upgrade_dock")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker.modulate = Color(1.0, 0.78, 0.32, 0.95)
	input_pickable = true
	input_event.connect(_on_input_event)


func _process(_delta: float) -> void:
	z_index = int(global_position.y / 10.0)
	marker.rotation = sin(Time.get_ticks_msec() / 420.0) * 0.07


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact") and get_tree().current_scene.is_nearest_interactable(self):
		get_tree().current_scene.buy_engine_upgrade(self)
		get_viewport().set_input_as_handled()


func upgrade_feedback() -> void:
	var tween := create_tween()
	tween.tween_property(marker, "scale", Vector2(1.22, 1.22), 0.12)
	tween.tween_property(marker, "scale", Vector2.ONE, 0.22)


func reset_interaction_state() -> void:
	player_near = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		get_tree().current_scene.show_prompt("E nâng cấp máy thuyền")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var scene = get_tree().current_scene
		if scene.player != null and not scene.player.input_blocked:
			var dist: float = global_position.distance_to(scene.player.global_position)
			if dist <= 680.0:
				scene.buy_engine_upgrade(self)
				get_viewport().set_input_as_handled()
			else:
				scene.ui.flash_prompt("Lái ghe lại gần hơn để nâng cấp máy")
