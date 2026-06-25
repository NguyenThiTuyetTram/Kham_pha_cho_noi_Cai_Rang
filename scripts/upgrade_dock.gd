extends Area2D

var player_near := false
@onready var marker: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker.modulate = Color(1.0, 0.78, 0.32, 0.95)


func _process(_delta: float) -> void:
	marker.rotation = sin(Time.get_ticks_msec() / 420.0) * 0.07


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact"):
		get_tree().current_scene.buy_engine_upgrade(self)
		get_viewport().set_input_as_handled()


func upgrade_feedback() -> void:
	var tween := create_tween()
	tween.tween_property(marker, "scale", Vector2(1.22, 1.22), 0.12)
	tween.tween_property(marker, "scale", Vector2.ONE, 0.22)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		get_tree().current_scene.show_prompt("E nâng cấp máy thuyền")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()
