import re

with open("scripts/game_manager.gd", "r", encoding="utf-8") as f:
    content = f.read()

# Replace active_quest with new vars
content = re.sub(
    r"var active_quest: int = 0",
    "var current_quest: Dictionary = {}\nvar available_quests: Dictionary = {}\nvar quest_cooldowns: Dictionary = {}",
    content
)

# Rename quests array to QUEST_TEMPLATES and add a new quest
quests_old = """var quests: Array[Dictionary] = [
	{
		"title": "Nộp tiền học phí",
		"description": "Tuần sau phải đóng tiền học 2 triệu cho bé Hà. Lấy 500k tiền vốn đi mua trái cây giao lấy tiền lời.",
		"map": "cai_rang",
		"giver": "teacher",
		"giver_name": "Cô Giáo",
		"dialogue": "Tuần sau là hạn chót nộp học phí cho bé Hà rồi, chắc là không hoãn được nữa đâu con à. Cô cũng biết hoàn cảnh 2 anh em khó khăn nhưng bé học rất tốt nếu dừng học ngay bây giờ thì tội cho nó lắm. Con cầm đỡ 500 ngàn tiền vốn, chịu khó đi lấy trái cây giao cho người ta để kiếm thêm tiền lời. Cố gắng xoay sở 2 triệu cho Hà được đi học tiếp.",
		"products": {"Trái cây": 3},
		"delivery": "Tiệm Ánh Đèn",
		"reward": 250,
		"rep": 1
	},
	{
		"title": "Giao dừa giải khát",
		"description": "Giao 2 trái nước dừa và 1 hộp bánh dân gian cho Bến Du Lịch.",
		"map": "ninh_kieu",
		"giver": "tour_guide",
		"giver_name": "Bàn Điều Tour",
		"dialogue": "Khách sắp xuống bến. Mua dùm chú 2 trái nước dừa và 1 hộp bánh dân gian giao bến du lịch. Tiền công và tiền hàng chú gửi 300 ngàn, ráng trả giá khéo để có lời nha con.",
		"products": {"Nước dừa": 2, "Bánh dân gian": 1},
		"delivery": "Bến Du Lịch",
		"reward": 300,
		"rep": 2
	},
	{
		"title": "Mua sỉ trái cây miệt vườn",
		"description": "Mua 4 giỏ trái cây và giao cho Nhà Vườn Chín Ngọt.",
		"map": "orchard",
		"giver": "farmer_coop",
		"giver_name": "Hợp Tác Xã",
		"dialogue": "Đi Kênh Vườn Trái Cây, gom 4 giỏ trái cây mang về Nhà Vườn Chín Ngọt. Tiền công 350 ngàn nè. Cố ép giá mấy sạp thuyền để dư ra chút đỉnh nghen.",
		"products": {"Trái cây": 4},
		"delivery": "Nhà Vườn Chín Ngọt",
		"reward": 350,
		"rep": 2
	}
]"""

quests_new = """var QUEST_TEMPLATES: Array[Dictionary] = [
	{
		"title": "Nộp tiền học phí",
		"description": "Tuần sau phải đóng tiền học 2 triệu cho bé Hà. Lấy 500k tiền vốn đi mua trái cây giao lấy tiền lời.",
		"map": "cai_rang",
		"giver": "teacher",
		"giver_name": "Cô Giáo",
		"dialogue": "Tuần sau là hạn chót nộp học phí cho bé Hà rồi, chắc là không hoãn được nữa đâu con à. Cô cũng biết hoàn cảnh 2 anh em khó khăn nhưng bé học rất tốt nếu dừng học ngay bây giờ thì tội cho nó lắm. Con cầm đỡ 500 ngàn tiền vốn, chịu khó đi lấy trái cây giao cho người ta để kiếm thêm tiền lời. Cố gắng xoay sở 2 triệu cho Hà được đi học tiếp.",
		"products": {"Trái cây": 3},
		"delivery": "Tiệm Ánh Đèn",
		"reward": 250,
		"rep": 1
	},
	{
		"title": "Giao dừa giải khát",
		"description": "Giao 2 trái nước dừa và 1 hộp bánh dân gian cho Bến Du Lịch.",
		"map": "ninh_kieu",
		"giver": "tour_guide",
		"giver_name": "Bàn Điều Tour",
		"dialogue": "Khách sắp xuống bến. Mua dùm chú 2 trái nước dừa và 1 hộp bánh dân gian giao bến du lịch. Tiền công và tiền hàng chú gửi 300 ngàn, ráng trả giá khéo để có lời nha con.",
		"products": {"Nước dừa": 2, "Bánh dân gian": 1},
		"delivery": "Bến Du Lịch",
		"reward": 300,
		"rep": 2
	},
	{
		"title": "Mua sỉ trái cây miệt vườn",
		"description": "Mua 4 giỏ trái cây và giao cho Nhà Vườn Chín Ngọt.",
		"map": "orchard",
		"giver": "farmer_coop",
		"giver_name": "Hợp Tác Xã",
		"dialogue": "Đi Kênh Vườn Trái Cây, gom 4 giỏ trái cây mang về Nhà Vườn Chín Ngọt. Tiền công 350 ngàn nè. Cố ép giá mấy sạp thuyền để dư ra chút đỉnh nghen.",
		"products": {"Trái cây": 4},
		"delivery": "Nhà Vườn Chín Ngọt",
		"reward": 350,
		"rep": 2
	},
	{
		"title": "Giao hàng thiết yếu",
		"description": "Mua 2 bó hoa tươi và 1 bánh dân gian giao cho Dãy Nhà Ven Sông.",
		"map": "cai_rang",
		"giver": "hub_cai_rang",
		"giver_name": "Trạm Điều Phối",
		"dialogue": "Bà con ven sông đang cần đồ cúng rằm. Lấy 2 bó hoa và 1 hộp bánh dân gian giao qua đó lẹ nha cháu. Trạm trả 300 ngàn cho chuyến này.",
		"products": {"Hoa tươi": 2, "Bánh dân gian": 1},
		"delivery": "Dãy Nhà Ven Sông",
		"reward": 300,
		"rep": 1
	}
]"""
content = content.replace(quests_old, quests_new)

# Update _ready to spawn quests
ready_old = """	_apply_map("cai_rang", Vector2(960, 760))
	_refresh_ui()
	_intro_sequence()"""
ready_new = """	_apply_map("cai_rang", Vector2(960, 760))
	_spawn_initial_quests()
	_refresh_ui()
	_intro_sequence()"""
content = content.replace(ready_old, ready_new)

# Add spawn func and cooldown process
spawn_func = """
func _spawn_initial_quests() -> void:
	for t in QUEST_TEMPLATES:
		if t["giver_name"] != "Cô Giáo":
			available_quests[t["giver_name"]] = t.duplicate()
"""
content += spawn_func

# Update intro sequence
intro_old = """		var q := quests[0]
		ui.show_dialogue(str(q["giver_name"]), str(q["dialogue"]), false)"""
intro_new = """		var q := QUEST_TEMPLATES[0]
		ui.show_dialogue(str(q["giver_name"]), str(q["dialogue"]), false)"""
content = content.replace(intro_old, intro_new)

intro_old2 = """						ui.show_map_banner(str(_current_map()["name"]), "Đi mua %s giao cho %s." % [q["products"].keys()[0], q["delivery"]])
						quest_accepted = true"""
intro_new2 = """						ui.show_map_banner(str(_current_map()["name"]), "Đi mua %s giao cho %s." % [q["products"].keys()[0], q["delivery"]])
						current_quest = q.duplicate()
						quest_accepted = true"""
content = content.replace(intro_old2, intro_new2)

# Update _process to handle win/lose and cooldowns
process_old = """	if is_time_running:
		game_time_minutes += delta * 15.0
		if game_time_minutes >= 1440.0:
			game_time_minutes -= 1440.0
			current_day += 1
		var h: int = int(game_time_minutes) / 60
		var m: int = int(game_time_minutes) % 60
		if ui != null:
			ui.update_time_ui(current_day, h, m)"""

process_new = """	if is_time_running:
		game_time_minutes += delta * 15.0
		if game_time_minutes >= 1440.0:
			game_time_minutes -= 1440.0
			current_day += 1
		var h: int = int(game_time_minutes) / 60
		var m: int = int(game_time_minutes) % 60
		if ui != null:
			ui.update_time_ui(current_day, h, m)
		
		_process_quest_cooldowns(delta)
		
		if money >= 2000000 / 1000: # 2 million VND (we use 1k = 1 money) -> so 2000
			_st.call("change_scene", "res://scenes/WinScreen.tscn")
			is_time_running = false
		elif current_day > 7:
			_st.call("change_scene", "res://scenes/BadEnding.tscn")
			is_time_running = false"""
content = content.replace(process_old, process_new)

cooldown_func = """
func _process_quest_cooldowns(delta: float) -> void:
	# Convert delta to game minutes
	var elapsed_mins = delta * 15.0
	var keys_to_remove = []
	for giver in quest_cooldowns.keys():
		quest_cooldowns[giver] -= elapsed_mins
		if quest_cooldowns[giver] <= 0:
			keys_to_remove.append(giver)
	
	for giver in keys_to_remove:
		quest_cooldowns.erase(giver)
		# Spawn a new random quest for this giver
		var templates = []
		for t in QUEST_TEMPLATES:
			if t["giver_name"] == giver:
				templates.append(t)
		if templates.size() > 0:
			var idx = randi() % templates.size()
			available_quests[giver] = templates[idx].duplicate()
"""
content += cooldown_func

# Fix active_quest reference
active_quest_old = """func _active_quest() -> Dictionary:
	return quests[min(active_quest, quests.size() - 1)] as Dictionary"""
active_quest_new = """func _active_quest() -> Dictionary:
	return current_quest"""
content = content.replace(active_quest_old, active_quest_new)

# Fix accept_quest
accept_old = """func accept_quest(giver_node: Area2D) -> void:
	var quest: Dictionary = _active_quest()
	var giver_id: String = str(giver_node.get("board_id")) if giver_node.get("board_id") else ""
	var giver_name: String = str(giver_node.get("merchant_name")) if giver_node.get("merchant_name") else ""
	
	if quest_accepted:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Bạn đang theo hợp đồng hiện tại")
		return
	if (giver_id != "" and quest.get("giver", "") != giver_id) and (giver_name != "" and quest.get("giver_name", "") != giver_name):
		_st.call("play_fail_sfx")
		ui.flash_prompt("Hợp đồng hiện tại không nhận ở đây")
		return
	quest_accepted = true
	if giver_node.has_method("accept_feedback"):
		giver_node.call("accept_feedback")
	elif giver_node.has_method("purchase_feedback"):
		giver_node.call("purchase_feedback")
	_refresh_ui()
	
	ui.show_dialogue(str(quest.get("giver_name", "Nhiệm vụ")), str(quest.get("dialogue", "Nhận đơn hàng mới.")), true)"""

accept_new = """func accept_quest(giver_node: Area2D) -> void:
	var giver_name: String = str(giver_node.get("merchant_name")) if giver_node.get("merchant_name") else ""
	
	if quest_accepted:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Bạn đang theo hợp đồng hiện tại")
		return
		
	if not available_quests.has(giver_name):
		_st.call("play_fail_sfx")
		ui.flash_prompt("NPC này hiện chưa có nhiệm vụ")
		return
		
	current_quest = available_quests[giver_name].duplicate()
	available_quests.erase(giver_name)
	quest_accepted = true
	
	if giver_node.has_method("accept_feedback"):
		giver_node.call("accept_feedback")
	elif giver_node.has_method("purchase_feedback"):
		giver_node.call("purchase_feedback")
	_refresh_ui()
	
	ui.show_dialogue(str(current_quest.get("giver_name", "Nhiệm vụ")), str(current_quest.get("dialogue", "Nhận đơn hàng mới.")), true)"""
content = content.replace(accept_old, accept_new)

# Fix complete delivery advance quest
advance_old = """func _advance_quest() -> void:
	var quest := _active_quest()
	active_quest += 1
	quest_accepted = false
	if active_quest >= quests.size():
		_st.call("change_scene", "res://scenes/WinScreen.tscn")
		return
	ui.show_celebration("Hoàn thành nhiệm vụ!", quest["title"])
	_refresh_ui()"""

advance_new = """func _advance_quest() -> void:
	var quest := _active_quest()
	quest_accepted = false
	
	# Start cooldown for the giver
	var giver = quest.get("giver_name", "")
	if giver != "":
		# Cooldown of 4 to 8 in-game hours
		quest_cooldowns[giver] = randf_range(240, 480)
		
	ui.show_celebration("Hoàn thành nhiệm vụ!", quest["title"])
	_refresh_ui()"""
content = content.replace(advance_old, advance_new)

with open("scripts/game_manager.gd", "w", encoding="utf-8") as f:
    f.write(content)

print("game_manager updated successfully.")
