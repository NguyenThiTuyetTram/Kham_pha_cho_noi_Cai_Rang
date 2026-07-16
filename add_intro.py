import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# Update _ready to call _spawn_initial_quests and _intro_sequence
ready_old = """	_apply_map("cai_rang", Vector2(960, 760))
	_refresh_ui()
	ui.show_map_banner(str(_current_map()["name"]), "Tìm điểm nhận nhiệm vụ để bắt đầu hợp đồng đầu tiên.")"""

ready_new = """	_apply_map("cai_rang", Vector2(960, 760))
	_spawn_initial_quests()
	_refresh_ui()
	_intro_sequence()"""

if ready_old in text:
    text = text.replace(ready_old, ready_new)

# Add _intro_sequence func
intro_func = """
func _intro_sequence() -> void:
	player.input_blocked = true
	var narrator_text = "Ở gần khu chợ nổi Cái Răng có hai anh em mồ côi cha mẹ. Người anh làm đủ nghề để nuôi nhỏ em ăn học. Hôm nay lại đến hạn nộp tiền học phí cho nhỏ em."
	
	ui.play_intro_cutscene(narrator_text, func():
		var q := QUEST_TEMPLATES[0]
		ui.show_dialogue(str(q["giver_name"]), str(q["dialogue"]), false)
		
		var choices: Array = []
		choices.append({
			"text": "Dạ con đang cố đi làm thêm đây cô.",
			"callback": func():
				ui.hide_dialogue()
				ui.show_dialogue("Người anh (Bạn)", "Dạ con đang cố đi làm thêm gom đủ tiền đây cô.", false)
				var inner_choices: Array = []
				inner_choices.append({
					"text": "Bắt đầu làm việc",
					"callback": func():
						ui.hide_dialogue()
						player.input_blocked = false
						ui.show_map_banner(str(_current_map()["name"]), "Đi mua %s giao cho %s." % [q["products"].keys()[0], q["delivery"]])
						current_quest = q.duplicate()
						quest_accepted = true
						_refresh_ui()
				})
				ui.show_choices(inner_choices)
		})
		ui.show_choices(choices)
	)
"""

if "func _intro_sequence" not in text:
    text = text.replace("func _unhandled_input(event: InputEvent) -> void:", intro_func + "\nfunc _unhandled_input(event: InputEvent) -> void:")

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Intro added.")
