extends Control

@export var is_how_to_play := false
@export var is_win_screen := false

const GAME_SCENE := "res://scenes/Game.tscn"
const HOW_TO_PLAY_SCENE := "res://scenes/HowToPlay.tscn"
const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
@onready var _st: Node = get_node("/root/SceneTransition")

func _ready() -> void:
	_build_screen()


func _build_screen() -> void:
	var background := TextureRect.new()
	background.texture = load("res://assets/river_market_background.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.04, 0.42)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var panel := PanelContainer.new()
	var panel_height := 360 if is_how_to_play or is_win_screen else 430
	panel.custom_minimum_size = Vector2(620, panel_height)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -310
	panel.offset_right = 310
	panel.offset_top = -panel_height / 2.0
	panel.offset_bottom = panel_height / 2.0
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.045, 0.075, 0.72)
	panel_style.border_color = Color(0.0, 0.85, 0.95, 0.62)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.shadow_color = Color(0.95, 0.25, 0.75, 0.22)
	panel_style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)

	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 40 if not is_how_to_play else 44)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.42))
	if is_win_screen:
		title.text = "Hoàn thành chuyến giao hàng!"
	elif is_how_to_play:
		title.text = "Hướng Dẫn"
	else:
		title.text = "Khám Phá Chợ Nổi Cái Răng"
	box.add_child(title)

	if is_win_screen:
		var summary := Label.new()
		summary.text = "Bạn đã đi qua Cái Răng, Bến Ninh Kiều, Kênh Vườn Trái Cây và Làng Đèn Lồng để hoàn thành đêm hội."
		summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.add_theme_font_size_override("font_size", 24)
		summary.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
		summary.custom_minimum_size = Vector2(540, 90)
		box.add_child(summary)
		box.add_child(_make_button("Chơi lại", _play))
		box.add_child(_make_button("Menu chính", _go_main_menu))
	elif is_how_to_play:
		var instructions := Label.new()
		instructions.text = "WASD: Di chuyển thuyền\nE: Nhận nhiệm vụ / mua hàng / giao hàng / chụp ảnh / đi cổng sông\nMỗi hợp đồng phải nhận tại trạm đặc biệt trên đúng bản đồ.\nGame có 4 bản đồ lớn: Cái Răng, Bến Ninh Kiều, Kênh Vườn Trái Cây, Làng Đèn Lồng.\nĐọc bảng tên sạp, điểm giao và điểm nhận nhiệm vụ để đi đúng tuyến."
		instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		instructions.add_theme_font_size_override("font_size", 23)
		instructions.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
		instructions.custom_minimum_size = Vector2(540, 170)
		box.add_child(instructions)
		box.add_child(_make_button("Quay lại", _go_main_menu))
	else:
		var subtitle := Label.new()
		subtitle.text = "Một đêm chợ nổi ấm áp, neon và đầy hương trái cây miền Tây."
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		subtitle.add_theme_font_size_override("font_size", 20)
		subtitle.add_theme_color_override("font_color", Color(0.82, 0.95, 1.0))
		box.add_child(subtitle)
		box.add_child(_make_button("Chơi", _play))
		box.add_child(_make_button("Hướng dẫn", _how_to_play))
		box.add_child(_make_button("Thoát", _quit))


func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 48)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.95, 1.0, 1.0))
	button.pressed.connect(callback)
	return button


func _play() -> void:
	_st.call("change_scene", GAME_SCENE)


func _how_to_play() -> void:
	_st.call("change_scene", HOW_TO_PLAY_SCENE)


func _go_main_menu() -> void:
	_st.call("change_scene", MAIN_MENU_SCENE)


func _quit() -> void:
	get_tree().quit()
