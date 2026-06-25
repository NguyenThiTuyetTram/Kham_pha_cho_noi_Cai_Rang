extends Area2D

@export var merchant_name := "Cô Sáu"
@export var product_name := "Trái cây"
@export var price := 50
@export var stock := 6

var player_near := false
var name_label: Label
@onready var fruit_icon: Sprite2D = $FruitIcon

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	fruit_icon.modulate = Color(1, 1, 1, 0.0)
	_create_nameplate()
	_update_nameplate()


func _process(delta: float) -> void:
	var target_alpha := 1.0 if player_near and stock > 0 else 0.0
	fruit_icon.modulate.a = move_toward(fruit_icon.modulate.a, target_alpha, delta * 5.0)
	if player_near:
		fruit_icon.scale = Vector2.ONE * (0.92 + sin(Time.get_ticks_msec() / 170.0) * 0.06)
	_update_nameplate()


func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact"):
		get_tree().current_scene.buy_from_merchant(self)
		_update_prompt()
		get_viewport().set_input_as_handled()


func purchase_feedback() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)
	tween.tween_property(self, "scale", Vector2.ONE, 0.18)


func _update_prompt() -> void:
	if not player_near:
		return
	if stock <= 0:
		get_tree().current_scene.show_prompt("%s đã hết hàng" % merchant_name)
	else:
		get_tree().current_scene.show_prompt("E mua %s - %dk (%s còn %d)" % [product_name, price, merchant_name, stock])


func _create_nameplate() -> void:
	name_label = Label.new()
	name_label.position = Vector2(-150, -145)
	name_label.size = Vector2(300, 58)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38))
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	name_label.add_theme_constant_override("outline_size", 5)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(name_label)


func _update_nameplate() -> void:
	if name_label == null:
		return
	name_label.text = "%s\n%s - %dk" % [merchant_name, product_name, price]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		_update_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		get_tree().current_scene.hide_prompt()
