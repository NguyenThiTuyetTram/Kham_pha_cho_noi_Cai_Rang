extends Area2D

@export var current_force := Vector2(38, 0)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.external_force += current_force * 0.018


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().current_scene.show_prompt("Dòng nước đang đẩy thuyền")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().current_scene.hide_prompt()
