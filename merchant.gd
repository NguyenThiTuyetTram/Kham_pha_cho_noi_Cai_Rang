extends Area2D

@onready var icon = $Icon

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _process(delta):
	# Hiệu ứng nổi bồng bềnh cho Icon
	icon.position.y = -140 + sin(Time.get_ticks_msec() / 200.0) * 10

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var main = get_tree().current_scene
		if main.has_method("show_interaction"):
			main.show_interaction(true, self)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		var main = get_tree().current_scene
		if main.has_method("show_interaction"):
			main.show_interaction(false, self)

func interact():
	var main = get_tree().current_scene
	if main.money >= 50:
		main.money -= 50
		main.inventory.append("Trái Cây")
		main.update_ui()
		# Bật nháy icon màu xanh báo hiệu mua thành công
		icon.modulate = Color(0, 1, 0)
		await get_tree().create_timer(0.2).timeout
		icon.modulate = Color(1, 1, 1)
