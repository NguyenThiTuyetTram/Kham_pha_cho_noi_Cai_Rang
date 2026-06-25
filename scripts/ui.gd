extends CanvasLayer

var money_label: Label
var map_label: Label
var cargo_label: Label
var reputation_label: Label
var engine_label: Label
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

func _ready() -> void:
	_build_hud()


func update_stats(money: int, cargo_text: String, reputation: int, engine_level: int, map_name: String) -> void:
	if money_label == null:
		return
	money_label.text = "Tiền: %dk" % money
	map_label.text = "Khu vực: " + map_name
	cargo_label.text = "Khoang hàng: " + cargo_text
	reputation_label.text = "Danh tiếng: %d" % reputation
	engine_label.text = "Máy thuyền: cấp %d" % engine_level


func set_mission(text: String) -> void:
	mission_label.text = "Nhiệm vụ: " + text


func set_progress(text: String) -> void:
	progress_label.text = "Tiến độ: " + text


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


func show_dialogue(speaker: String, text: String) -> void:
	dialogue_speaker.text = speaker
	dialogue_text.text = text
	dialogue_panel.visible = true
	dialogue_panel.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(dialogue_panel, "modulate:a", 1.0, 0.12)
	tween.tween_interval(2.2)
	tween.tween_property(dialogue_panel, "modulate:a", 0.0, 0.22)
	await tween.finished
	dialogue_panel.visible = false


func _build_hud() -> void:
	var stats_panel := PanelContainer.new()
	stats_panel.position = Vector2(20, 18)
	stats_panel.size = Vector2(430, 236)
	stats_panel.custom_minimum_size = Vector2(430, 236)
	stats_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.015, 0.025, 0.045, 0.68), Color(0.0, 0.75, 0.84, 0.58)))
	add_child(stats_panel)

	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation", 4)
	stats_panel.add_child(stats)

	money_label = _hud_label(21, Color(1.0, 0.83, 0.43))
	map_label = _hud_label(16, Color(0.62, 0.95, 1.0))
	cargo_label = _hud_label(16, Color(0.82, 1.0, 0.96))
	reputation_label = _hud_label(16, Color(1.0, 0.55, 0.9))
	engine_label = _hud_label(16, Color(0.82, 0.92, 1.0))
	mission_label = _hud_label(15, Color(1.0, 0.94, 0.8))
	progress_label = _hud_label(15, Color(0.72, 1.0, 0.92))
	stats.add_child(money_label)
	stats.add_child(map_label)
	stats.add_child(cargo_label)
	stats.add_child(reputation_label)
	stats.add_child(engine_label)
	stats.add_child(mission_label)
	stats.add_child(progress_label)

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
	dialogue_panel.size = Vector2(660, 108)
	dialogue_panel.custom_minimum_size = Vector2(660, 108)
	dialogue_panel.anchor_left = 0.5
	dialogue_panel.anchor_right = 0.5
	dialogue_panel.anchor_top = 1.0
	dialogue_panel.anchor_bottom = 1.0
	dialogue_panel.offset_left = -330
	dialogue_panel.offset_right = 330
	dialogue_panel.offset_top = -212
	dialogue_panel.offset_bottom = -104
	dialogue_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.01, 0.018, 0.035, 0.9), Color(0.0, 0.9, 1.0, 0.88)))
	add_child(dialogue_panel)

	var dialogue_box: VBoxContainer = VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 5)
	dialogue_panel.add_child(dialogue_box)

	dialogue_speaker = _hud_label(17, Color(1.0, 0.78, 0.34))
	dialogue_text = _hud_label(16, Color(0.9, 0.98, 1.0))
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_box.add_child(dialogue_speaker)
	dialogue_box.add_child(dialogue_text)


func _hud_label(size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


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
