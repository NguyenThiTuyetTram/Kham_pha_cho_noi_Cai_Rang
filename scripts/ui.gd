extends CanvasLayer

var money_label: Label
var map_label: Label
var time_label: Label
var cargo_label: Label
var reputation_label: Label
var engine_label: Label
var _money_color := Color(1.0, 0.83, 0.43)
var _rep_color := Color(1.0, 0.55, 0.9)
var _engine_color := Color(0.82, 0.92, 1.0)
var mission_label: Label
var progress_label: Label
var prompt_panel: PanelContainer
var prompt_label: Label
var banner_panel: PanelContainer
var banner_title: Label
var banner_subtitle: Label
var dialogue_panel: PanelContainer
var dialogue_speaker: Label
var dialogue_text: Label
var choices_container: HBoxContainer
var dialogue_tween: Tween
var _dialogue_full_text := ""
var _dialogue_dismiss_enabled := true
var _dialogue_typewriter_tween: Tween
var voice_player: AudioStreamPlayer

var bargain_panel: PanelContainer
var bargain_indicator: ColorRect
var bargain_target: ColorRect
var is_bargaining := false
var bargain_speed := 300.0
var bargain_dir := 1.0
var bargain_callback: Callable

var _celebration_panel: PanelContainer
var _celebration_title: Label
var _celebration_subtitle: Label
var _celebration_tween: Tween

var _progress_bar: ColorRect
var _progress_bg: ColorRect
var _progress_visible := false

var _waypoint_container: Node2D
var _waypoint_arrows: Array[Control] = []
var _prev_money := -1
var _prev_reputation := -1
var _prev_engine := -1
var hud_visible := true
var _stats_panel: PanelContainer

var intro_panel: ColorRect
var intro_text: Label
var _intro_tween: Tween

func _ready() -> void:
	voice_player = AudioStreamPlayer.new()
	add_child(voice_player)
	_build_hud()
	_build_bargain_ui()
	_build_intro_ui()

func _build_intro_ui() -> void:
	intro_panel = ColorRect.new()
	intro_panel.color = Color.BLACK
	intro_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_panel.visible = false
	intro_panel.z_index = 100
	add_child(intro_panel)

	intro_text = Label.new()
	intro_text.add_theme_font_size_override("font_size", 28)
	intro_text.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	intro_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intro_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	intro_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_text.offset_left = 150
	intro_text.offset_right = -150
	intro_panel.add_child(intro_text)

func play_intro_cutscene(text: String, callback: Callable) -> void:
	intro_panel.visible = true
	intro_panel.modulate.a = 1.0
	intro_text.text = ""
	_play_voice_for_text(text, "")
	
	var type_speed: float = 28.0
	if _intro_tween: _intro_tween.kill()
	_intro_tween = create_tween()
	_intro_tween.set_parallel(false)
	var char_count := text.length()
	for i in range(1, char_count + 1):
		_intro_tween.tween_callback(func(): intro_text.text = text.left(i))
		_intro_tween.tween_interval(1.0 / type_speed)
	_intro_tween.tween_interval(3.0)
	_intro_tween.tween_property(intro_panel, "modulate:a", 0.0, 1.5)
	_intro_tween.tween_callback(func():
		intro_panel.visible = false
		intro_panel.modulate.a = 1.0
		if callback: callback.call()
	)

func _process(delta: float) -> void:
	_update_arrow_positions()
	if is_bargaining and bargain_indicator != null:
		bargain_indicator.position.x += bargain_speed * bargain_dir * delta
		if bargain_indicator.position.x <= 20:
			bargain_indicator.position.x = 20
			bargain_dir = 1.0
		elif bargain_indicator.position.x >= 372:
			bargain_indicator.position.x = 372
			bargain_dir = -1.0

func _play_voice_for_text(text: String, speaker: String) -> void:
	return
	if voice_player == null: return
	var stream: AudioStream = null
	# Based on speaker or text content
	if "Ở gần khu chợ nổi Cái Răng" in text: stream = load("res://assets/voice/narrator_intro.mp3")
	elif "Tuần sau là hạn chót" in text: stream = load("res://assets/voice/intro_teacher.mp3")
	elif "Dạ con đang cố" in text: stream = load("res://assets/voice/intro_player.mp3")
	elif "Bánh dân gian nay ngon" in text: stream = load("res://assets/voice/merchant_ditu.mp3")
	elif "Nước dừa tươi rói" in text: stream = load("res://assets/voice/merchant_chubay.mp3")
	elif "Trái cây miệt vườn mới hái" in text: stream = load("res://assets/voice/merchant_anhhai.mp3")
	elif "Bún riêu nóng hổi" in text: stream = load("res://assets/voice/merchant_diba.mp3")
	elif "Đêm nay khách đông" in text: stream = load("res://assets/voice/quest_1.mp3")
	elif "Khách sắp xuống bến" in text: stream = load("res://assets/voice/quest_2.mp3")
	elif "Đi Kênh Vườn Trái Cây" in text: stream = load("res://assets/voice/quest_3.mp3")
	elif "Trời ơi bớt dữ" in text: stream = load("res://assets/voice/bargain_fail_female.mp3")
	elif "Ép giá chú quá" in text: stream = load("res://assets/voice/bargain_fail_male.mp3")
	elif "bán mở hàng lấy thảo" in text: stream = load("res://assets/voice/bargain_good_female.mp3")
	elif "Thấy con ngoan chú bớt" in text: stream = load("res://assets/voice/bargain_good_male.mp3")
	elif "Mắt con lẹ quá trời" in text: stream = load("res://assets/voice/bargain_perfect_female.mp3")
	elif "Hay quá con trai" in text: stream = load("res://assets/voice/bargain_perfect_male.mp3")
	elif "Cảm ơn con nhen" in text: stream = load("res://assets/voice/delivery_success.mp3")
	elif "tiền đâu con ơi" in text: stream = load("res://assets/voice/not_enough_money.mp3")
	elif "giá đó cô lỗ chết" in text: stream = load("res://assets/voice/bargain_fail_female.mp3")
	
	if stream:
		voice_player.stream = stream
		voice_player.play()

func update_time_ui(day: int, hour: int, minute: int) -> void:
	if time_label == null:
		return
	var period = "AM"
	var display_hour = hour
	if display_hour >= 12:
		period = "PM"
		if display_hour > 12:
			display_hour -= 12
	elif display_hour == 0:
		display_hour = 12
	time_label.text = "Ngày %d/7 - %02d:%02d %s" % [day, display_hour, minute, period]


func update_stats(money: int, cargo_text: String, reputation: int, engine_level: int, map_name: String) -> void:
	if money_label == null:
		return
	if money != _prev_money:
		_flash_label(money_label, _money_color)
		_prev_money = money
	if reputation != _prev_reputation:
		_flash_label(reputation_label, _rep_color)
		_prev_reputation = reputation
	if engine_level != _prev_engine:
		_flash_label(engine_label, _engine_color)
		_prev_engine = engine_level
	money_label.text = "Tiền: %dk" % money
	cargo_label.text = "Khoang hàng: " + cargo_text
	reputation_label.text = "Danh tiếng: %d" % reputation
	engine_label.text = "Máy thuyền: cấp %d" % engine_level
	map_label.text = "Khu vực: " + map_name


func set_mission(text: String) -> void:
	if mission_label == null:
		return
	mission_label.text = "Nhiệm vụ: " + text


func set_progress(text: String) -> void:
	if progress_label == null:
		return
	progress_label.text = text


func show_map_banner(title: String, subtitle: String) -> void:
	banner_title.text = title
	banner_subtitle.text = subtitle
	banner_panel.visible = true
	banner_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(banner_panel, "modulate:a", 1.0, 0.18)
	tween.tween_interval(1.8)
	tween.tween_property(banner_panel, "modulate:a", 0.0, 0.35)
	await tween.finished
	banner_panel.visible = false


func show_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_panel.visible = true


func hide_prompt() -> void:
	prompt_panel.visible = false


func flash_prompt(text: String) -> void:
	show_prompt(text)
	await get_tree().create_timer(1.35).timeout
	if prompt_label.text == text:
		hide_prompt()


func show_dialogue(speaker: String, text: String, auto_fade: bool = true) -> void:
	if dialogue_tween:
		dialogue_tween.kill()
	if _dialogue_typewriter_tween:
		_dialogue_typewriter_tween.kill()
	clear_choices()
	dialogue_speaker.text = speaker
	dialogue_text.text = ""
	_dialogue_full_text = text
	dialogue_panel.visible = true
	dialogue_panel.modulate.a = 1.0
	_dialogue_dismiss_enabled = false
	
	_play_voice_for_text(text, speaker)

	var type_speed: float = 28.0
	_dialogue_typewriter_tween = create_tween()
	_dialogue_typewriter_tween.set_parallel(false)
	var char_count := text.length()
	for i in range(1, char_count + 1):
		_dialogue_typewriter_tween.tween_callback(func(): dialogue_text.text = text.left(i))
		_dialogue_typewriter_tween.tween_interval(1.0 / type_speed)
	_dialogue_typewriter_tween.tween_callback(func():
		_dialogue_typewriter_tween = null
	)

	if auto_fade:
		await _dialogue_typewriter_tween.finished
		_dialogue_dismiss_enabled = true
		await _wait_for_dismiss()
		hide_dialogue()


func hide_dialogue() -> void:
	if dialogue_tween:
		dialogue_tween.kill()
	if _dialogue_typewriter_tween:
		_dialogue_typewriter_tween.kill()
		_dialogue_typewriter_tween = null
	if voice_player:
		voice_player.stop()
	_dialogue_dismiss_enabled = false
	clear_choices()
	dialogue_panel.visible = false


func _wait_for_dismiss() -> void:
	while _dialogue_dismiss_enabled and dialogue_panel.visible:
		await get_tree().process_frame


func _input(event: InputEvent) -> void:
	if is_bargaining:
		if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept") or event.is_action_pressed("interact") or (event is InputEventKey and event.keycode == KEY_SPACE and event.pressed and not event.echo):
			stop_bargain()
			get_viewport().set_input_as_handled()
		return

	if _dialogue_dismiss_enabled and dialogue_panel.visible:
		var should_dismiss := false
		if event.is_action_pressed("interact"):
			should_dismiss = true
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			should_dismiss = true
		elif event is InputEventKey and event.keycode == KEY_SPACE and not event.echo and event.pressed:
			should_dismiss = true

		if should_dismiss:
			_dialogue_dismiss_enabled = false
			if _dialogue_typewriter_tween:
				_dialogue_typewriter_tween.kill()
				_dialogue_typewriter_tween = null
				dialogue_text.text = _dialogue_full_text
			hide_dialogue()
			get_viewport().set_input_as_handled()


func show_choices(choices: Array) -> void:
	clear_choices()
	for choice in choices:
		var btn := Button.new()
		btn.text = choice["text"]
		btn.add_theme_font_size_override("font_size", 15)
		btn.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.3))
		btn.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.3))
		
		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = Color(0.03, 0.08, 0.15, 0.88)
		normal_style.border_color = Color(0.0, 0.7, 0.85, 0.6)
		normal_style.border_width_left = 1
		normal_style.border_width_top = 1
		normal_style.border_width_right = 1
		normal_style.border_width_bottom = 1
		normal_style.corner_radius_top_left = 4
		normal_style.corner_radius_top_right = 4
		normal_style.corner_radius_bottom_left = 4
		normal_style.corner_radius_bottom_right = 4
		normal_style.content_margin_left = 12
		normal_style.content_margin_right = 12
		normal_style.content_margin_top = 6
		normal_style.content_margin_bottom = 6
		
		var hover_style := normal_style.duplicate() as StyleBoxFlat
		hover_style.bg_color = Color(0.05, 0.14, 0.25, 0.92)
		hover_style.border_color = Color(0.0, 0.9, 1.0, 0.85)
		
		btn.add_theme_stylebox_override("normal", normal_style)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("focus", hover_style)
		btn.add_theme_stylebox_override("pressed", hover_style)
		
		var current_choice = choice
		btn.pressed.connect(func():
			clear_choices()
			current_choice["callback"].call()
		)
		choices_container.add_child(btn)
		
	if choices_container.get_child_count() > 0:
		choices_container.get_child(0).grab_focus()


func clear_choices() -> void:
	if choices_container != null:
		for child in choices_container.get_children():
			child.queue_free()


func _build_hud() -> void:
	_stats_panel = PanelContainer.new()
	_stats_panel.position = Vector2(20, 18)
	_stats_panel.size = Vector2(430, 236)
	_stats_panel.custom_minimum_size = Vector2(430, 236)
	_stats_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.015, 0.025, 0.045, 0.68), Color(0.0, 0.75, 0.84, 0.58)))
	add_child(_stats_panel)

	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation", 4)
	_stats_panel.add_child(stats)

	money_label = _hud_label(21, Color(1.0, 0.83, 0.43))
	time_label = _hud_label(18, Color(1.0, 0.65, 0.4))
	map_label = _hud_label(16, Color(0.62, 0.95, 1.0))
	cargo_label = _hud_label(16, Color(0.82, 1.0, 0.96))
	reputation_label = _hud_label(16, Color(1.0, 0.55, 0.9))
	engine_label = _hud_label(16, Color(0.82, 0.92, 1.0))
	mission_label = _hud_label(15, Color(1.0, 0.94, 0.8))
	progress_label = _hud_label(15, Color(0.72, 1.0, 0.92))
	stats.add_child(_hud_row(money_label, Color(1.0, 0.83, 0.43)))
	stats.add_child(_hud_row(time_label, Color(1.0, 0.65, 0.4)))
	stats.add_child(_hud_row(map_label, Color(0.62, 0.95, 1.0)))
	stats.add_child(_hud_row(cargo_label, Color(0.82, 1.0, 0.96)))
	stats.add_child(_hud_row(reputation_label, Color(1.0, 0.55, 0.9)))
	stats.add_child(_hud_row(engine_label, Color(0.82, 0.92, 1.0)))
	stats.add_child(_hud_row(mission_label, Color(1.0, 0.94, 0.8)))
	stats.add_child(_hud_row(progress_label, Color(0.72, 1.0, 0.92)))

	banner_panel = PanelContainer.new()
	banner_panel.visible = false
	banner_panel.size = Vector2(560, 86)
	banner_panel.custom_minimum_size = Vector2(560, 86)
	banner_panel.anchor_left = 0.5
	banner_panel.anchor_right = 0.5
	banner_panel.offset_left = -280
	banner_panel.offset_right = 280
	banner_panel.offset_top = 20
	banner_panel.offset_bottom = 106
	banner_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.015, 0.02, 0.04, 0.82), Color(1.0, 0.72, 0.25, 0.85)))
	add_child(banner_panel)

	var banner_box := VBoxContainer.new()
	banner_box.alignment = BoxContainer.ALIGNMENT_CENTER
	banner_box.add_theme_constant_override("separation", 2)
	banner_panel.add_child(banner_box)

	banner_title = _hud_label(25, Color(1.0, 0.83, 0.38))
	banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_subtitle = _hud_label(16, Color(0.86, 0.98, 1.0))
	banner_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_box.add_child(banner_title)
	banner_box.add_child(banner_subtitle)

	prompt_panel = PanelContainer.new()
	prompt_panel.visible = false
	prompt_panel.size = Vector2(500, 56)
	prompt_panel.custom_minimum_size = Vector2(500, 56)
	prompt_panel.anchor_left = 0.5
	prompt_panel.anchor_right = 0.5
	prompt_panel.anchor_top = 1.0
	prompt_panel.anchor_bottom = 1.0
	prompt_panel.offset_left = -250
	prompt_panel.offset_right = 250
	prompt_panel.offset_top = -92
	prompt_panel.offset_bottom = -36
	prompt_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.02, 0.015, 0.035, 0.84), Color(1.0, 0.28, 0.72, 0.82)))
	add_child(prompt_panel)

	prompt_label = _hud_label(20, Color(1.0, 0.93, 0.65))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_panel.add_child(prompt_label)

	dialogue_panel = PanelContainer.new()
	dialogue_panel.visible = false
	dialogue_panel.size = Vector2(660, 160)
	dialogue_panel.custom_minimum_size = Vector2(660, 160)
	dialogue_panel.anchor_left = 0.5
	dialogue_panel.anchor_right = 0.5
	dialogue_panel.anchor_top = 1.0
	dialogue_panel.anchor_bottom = 1.0
	dialogue_panel.offset_left = -330
	dialogue_panel.offset_right = 330
	dialogue_panel.offset_top = -272
	dialogue_panel.offset_bottom = -104
	dialogue_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.01, 0.018, 0.035, 0.9), Color(0.0, 0.9, 1.0, 0.88)))
	add_child(dialogue_panel)

	var dialogue_box: VBoxContainer = VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 6)
	dialogue_panel.add_child(dialogue_box)

	dialogue_speaker = _hud_label(17, Color(1.0, 0.78, 0.34))
	dialogue_text = _hud_label(16, Color(0.9, 0.98, 1.0))
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_box.add_child(dialogue_speaker)
	dialogue_box.add_child(dialogue_text)
	
	choices_container = HBoxContainer.new()
	choices_container.alignment = BoxContainer.ALIGNMENT_CENTER
	choices_container.add_theme_constant_override("separation", 12)
	dialogue_box.add_child(choices_container)


	# ── Celebration panel ──
	_celebration_panel = PanelContainer.new()
	_celebration_panel.visible = false
	_celebration_panel.size = Vector2(480, 140)
	_celebration_panel.custom_minimum_size = Vector2(480, 140)
	_celebration_panel.anchor_left = 0.5
	_celebration_panel.anchor_right = 0.5
	_celebration_panel.anchor_top = 0.5
	_celebration_panel.anchor_bottom = 0.5
	_celebration_panel.offset_left = -240
	_celebration_panel.offset_right = 240
	_celebration_panel.offset_top = -70
	_celebration_panel.offset_bottom = 70
	_celebration_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.01, 0.03, 0.06, 0.92), Color(1.0, 0.72, 0.25, 0.9)))
	add_child(_celebration_panel)

	var cbox := VBoxContainer.new()
	cbox.alignment = BoxContainer.ALIGNMENT_CENTER
	cbox.add_theme_constant_override("separation", 6)
	_celebration_panel.add_child(cbox)

	_celebration_title = _hud_label(28, Color(1.0, 0.85, 0.28))
	_celebration_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cbox.add_child(_celebration_title)

	_celebration_subtitle = _hud_label(18, Color(0.82, 1.0, 0.96))
	_celebration_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cbox.add_child(_celebration_subtitle)

	# ── Interaction progress bar ──
	var progress_root := PanelContainer.new()
	progress_root.visible = false
	progress_root.name = "InteractProgress"
	progress_root.size = Vector2(120, 12)
	progress_root.custom_minimum_size = Vector2(120, 12)
	progress_root.anchor_left = 0.5
	progress_root.anchor_right = 0.5
	progress_root.anchor_top = 1.0
	progress_root.anchor_bottom = 1.0
	progress_root.offset_left = -60
	progress_root.offset_right = 60
	progress_root.offset_top = -108
	progress_root.offset_bottom = -96
	progress_root.add_theme_stylebox_override("panel", _panel_style(Color(0.02, 0.015, 0.035, 0.7), Color(0.4, 0.6, 0.8, 0.4)))
	add_child(progress_root)

	_progress_bg = ColorRect.new()
	_progress_bg.color = Color(0.05, 0.05, 0.1, 0.4)
	_progress_bg.size = Vector2(112, 8)
	_progress_bg.position = Vector2(4, 2)
	progress_root.add_child(_progress_bg)

	_progress_bar = ColorRect.new()
	_progress_bar.color = Color(0.0, 0.9, 1.0, 0.9)
	_progress_bar.size = Vector2(0, 8)
	_progress_bar.position = Vector2(4, 2)
	progress_root.add_child(_progress_bar)

	# ── Waypoint container ──
	_waypoint_container = Node2D.new()
	_waypoint_container.name = "Waypoints"
	add_child(_waypoint_container)


func _hud_label(size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _hud_icon(color: Color) -> PanelContainer:
	var icon := PanelContainer.new()
	icon.size = Vector2(10, 10)
	icon.custom_minimum_size = Vector2(10, 10)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	icon.add_theme_stylebox_override("panel", style)
	return icon


func _hud_row(label: Label, color: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(_hud_icon(color))
	row.add_child(label)
	return row


func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 11
	style.content_margin_bottom = 11
	style.shadow_color = Color(0.0, 0.65, 0.72, 0.12)
	style.shadow_size = 8
	return style


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_TAB and event.pressed and not event.echo:
		toggle_hud()


func toggle_hud() -> void:
	hud_visible = not hud_visible
	if _stats_panel:
		_stats_panel.visible = hud_visible


func _flash_label(label: Label, original: Color) -> void:
	label.add_theme_color_override("font_color", Color.WHITE)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(label):
		label.add_theme_color_override("font_color", original)


func show_reward_popup(money_gain: int, rep_gain: int, items_text: String = "") -> void:
	var panel := PanelContainer.new()
	panel.size = Vector2(300, 96)
	panel.custom_minimum_size = Vector2(300, 96)
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -48
	panel.offset_bottom = 48
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.01, 0.02, 0.05, 0.88), Color(1.0, 0.72, 0.25, 0.85)))
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	if money_gain > 0:
		var ml := _hud_label(22, Color(1.0, 0.83, 0.43))
		ml.text = "+%dk" % money_gain
		ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(ml)

	if rep_gain > 0:
		var rl := _hud_label(18, Color(1.0, 0.55, 0.9))
		rl.text = "Danh tiếng +%d" % rep_gain
		rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(rl)

	if items_text != "":
		var il := _hud_label(16, Color(0.82, 1.0, 0.96))
		il.text = items_text
		il.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(il)

	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.tween_property(panel, "offset_top", panel.offset_top - 20, 0.2)
	tween.tween_interval(1.2)
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	await tween.finished
	if is_instance_valid(panel):
		panel.queue_free()


func reward_sparkle(color: Color = Color(1.0, 0.83, 0.43)) -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var center := viewport.get_visible_rect().size / 2
	for i in range(8):
		var p := ColorRect.new()
		p.size = Vector2(5, 5)
		p.color = color
		p.position = center - Vector2(2.5, 2.5)
		add_child(p)
		var angle := TAU * float(i) / 8.0
		var dist := randf_range(50, 110)
		var target := Vector2(cos(angle), sin(angle)) * dist
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(p, "position", center + target, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(p, "modulate:a", 0.0, 0.5)
		tween.finished.connect(p.queue_free)


# ── Waypoint markers ──

func update_waypoints(targets: Array) -> void:
	_clear_waypoints()
	for t in targets:
		var target: Dictionary = t as Dictionary
		var node: Node2D = target.get("node") as Node2D
		if node == null or not is_instance_valid(node) or not node.visible:
			continue
		var color: Color = target.get("color", Color.WHITE)
		var label_text: String = target.get("label", "")

		var arrow := PanelContainer.new()
		arrow.visible = false
		arrow.size = Vector2(100, 28)
		arrow.custom_minimum_size = Vector2(100, 28)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.0, 0.0, 0.0, 0.55)
		style.border_color = color
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		arrow.add_theme_stylebox_override("panel", style)

		var inner := HBoxContainer.new()
		inner.alignment = BoxContainer.ALIGNMENT_CENTER
		arrow.add_child(inner)

		var arrow_label := Label.new()
		arrow_label.text = "▲"
		arrow_label.add_theme_font_size_override("font_size", 14)
		arrow_label.add_theme_color_override("font_color", color)
		arrow_label.add_theme_constant_override("outline_size", 2)
		arrow_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		inner.add_child(arrow_label)

		var dist_label := Label.new()
		dist_label.text = label_text
		dist_label.add_theme_font_size_override("font_size", 12)
		dist_label.add_theme_color_override("font_color", color)
		dist_label.add_theme_constant_override("outline_size", 2)
		dist_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		dist_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		inner.add_child(dist_label)

		arrow.set_meta("target_node", node)
		arrow.set_meta("target_color", color)
		add_child(arrow)
		_waypoint_arrows.append(arrow)





func _update_arrow_positions() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var camera := viewport.get_camera_2d()
	if camera == null:
		return
	var screen_size := viewport.get_visible_rect().size
	var margin := 50.0

	for arrow in _waypoint_arrows:
		if not is_instance_valid(arrow):
			continue
		var target: Node2D = arrow.get_meta("target_node") as Node2D
		if target == null or not is_instance_valid(target) or not target.visible:
			arrow.visible = false
			continue

		var canvas_transform := camera.get_canvas_transform()
		var screen_pos := canvas_transform * target.global_position

		var on_screen := screen_pos.x >= -20 and screen_pos.x <= screen_size.x + 20 and screen_pos.y >= -20 and screen_pos.y <= screen_size.y + 20

		if on_screen:
			arrow.visible = false
			continue

		var center := screen_size / 2.0
		var dir := screen_pos - center
		var angle := atan2(dir.y, dir.x)

		var edge_pos := Vector2(
			clamp(screen_pos.x, margin, screen_size.x - margin),
			clamp(screen_pos.y, margin, screen_size.y - margin)
		)

		if edge_pos.x <= margin and angle > -PI * 0.5 and angle < PI * 0.5:
			edge_pos.x = margin
		elif edge_pos.x >= screen_size.x - margin:
			edge_pos.x = screen_size.x - margin
		if edge_pos.y <= margin:
			edge_pos.y = margin
		elif edge_pos.y >= screen_size.y - margin:
			edge_pos.y = screen_size.y - margin

		arrow.position = edge_pos - arrow.size / 2.0

		var arrow_label := arrow.get_child(0).get_child(0) as Label
		if arrow_label:
			var arrow_char := "^"
			if abs(angle) < PI * 0.25:
				arrow_char = "→"
			elif abs(angle) > PI * 0.75:
				arrow_char = "←"
			elif angle > 0:
				arrow_char = "↓"
			else:
				arrow_char = "↑"
			if abs(angle) > PI * 0.25 and abs(angle) < PI * 0.75:
				if angle > 0:
					arrow_char = "↓"
				else:
					arrow_char = "↑"
			arrow_label.text = arrow_char

		var dist := int(target.global_position.distance_to(camera.global_position) / 10.0)
		var dist_label := arrow.get_child(0).get_child(1) as Label
		if dist_label:
			dist_label.text = str(dist) + "m"

		arrow.visible = true


func _clear_waypoints() -> void:
	for arrow in _waypoint_arrows:
		if is_instance_valid(arrow):
			arrow.queue_free()
	_waypoint_arrows.clear()


# ── Interaction progress ──

func show_interact_progress(progress: float) -> void:
	if _progress_bar == null:
		return
	var root := _progress_bar.get_parent() as Control
	if root:
		root.visible = true
	_progress_bar.size.x = progress * 112.0
	_progress_visible = true


func hide_interact_progress() -> void:
	if _progress_bar == null:
		return
	var root := _progress_bar.get_parent() as Control
	if root:
		root.visible = false
	_progress_bar.size.x = 0.0
	_progress_visible = false


# ── Quest completion celebration ──

func show_celebration(title: String, subtitle: String) -> void:
	if _celebration_panel == null:
		return
	if _celebration_tween:
		_celebration_tween.kill()
	_celebration_title.text = title
	_celebration_subtitle.text = subtitle
	_celebration_panel.visible = true
	_celebration_panel.modulate.a = 0.0
	_celebration_panel.scale = Vector2(0.6, 0.6)

	_celebration_tween = create_tween()
	_celebration_tween.set_parallel(true)
	_celebration_tween.tween_property(_celebration_panel, "modulate:a", 1.0, 0.25)
	_celebration_tween.tween_property(_celebration_panel, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_celebration_tween.tween_interval(1.6)
	_celebration_tween.tween_property(_celebration_panel, "modulate:a", 0.0, 0.3)
	_celebration_tween.tween_property(_celebration_panel, "scale", Vector2(0.8, 0.8), 0.3)
	await _celebration_tween.finished
	_celebration_panel.visible = false
	_celebration_panel.scale = Vector2.ONE

func _build_bargain_ui() -> void:
	bargain_panel = PanelContainer.new()
	bargain_panel.visible = false
	bargain_panel.size = Vector2(400, 80)
	bargain_panel.anchor_left = 0.5
	bargain_panel.anchor_right = 0.5
	bargain_panel.anchor_top = 0.5
	bargain_panel.anchor_bottom = 0.5
	bargain_panel.offset_left = -200
	bargain_panel.offset_right = 200
	bargain_panel.offset_top = -120
	bargain_panel.offset_bottom = -40
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	style.border_color = Color(1.0, 0.85, 0.3, 0.8)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	bargain_panel.add_theme_stylebox_override("panel", style)
	add_child(bargain_panel)
	
	var inner = Control.new()
	bargain_panel.add_child(inner)
	
	var label = Label.new()
	label.text = "Bấm SPACE hoặc E khi vạch nằm trong vùng XANH LÁ!"
	label.position = Vector2(0, 10)
	label.size = Vector2(400, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	inner.add_child(label)
	
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 1.0)
	bg.size = Vector2(360, 24)
	bg.position = Vector2(20, 40)
	inner.add_child(bg)
	
	bargain_target = ColorRect.new()
	bargain_target.color = Color(0.1, 0.85, 0.2, 1.0)
	bargain_target.size = Vector2(60, 24)
	bargain_target.position = Vector2(120, 40)
	inner.add_child(bargain_target)
	
	bargain_indicator = ColorRect.new()
	bargain_indicator.color = Color(1.0, 0.9, 0.1, 1.0)
	bargain_indicator.size = Vector2(8, 36)
	bargain_indicator.position = Vector2(20, 34)
	inner.add_child(bargain_indicator)

func start_bargain(callback: Callable) -> void:
	is_bargaining = true
	bargain_callback = callback
	bargain_panel.visible = true
	bargain_indicator.position.x = 20
	bargain_dir = 1.0
	bargain_target.position.x = randf_range(60, 300)
	bargain_target.size.x = randf_range(30, 70)
	bargain_speed = randf_range(500, 800)

func stop_bargain() -> void:
	if not is_bargaining: return
	is_bargaining = false
	bargain_panel.visible = false
	var ix = bargain_indicator.position.x + 4
	var tx = bargain_target.position.x
	var tw = bargain_target.size.x
	var success = ix >= tx and ix <= tx + tw
	if bargain_callback:
		bargain_callback.call(success)
