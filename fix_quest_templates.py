import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# Make sure quests is removed and replaced by QUEST_TEMPLATES
# Since there are multiple quests blocks possible, we'll just replace the whole var quests array
match = re.search(r'var quests: Array\[Dictionary\] = \[.*?\]\n', text, re.DOTALL)
if match:
    quests_str = match.group(0)
    text = text.replace(quests_str, '''var QUEST_TEMPLATES: Array[Dictionary] = [
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
]
''')

# Also restore _intro_sequence from before!
intro_old = '''func _intro_sequence() -> void:
	player.input_blocked = true
	var narrator_text = "Ở gần khu chợ nổi Cái Răng có hai anh em mồ côi cha mẹ. Người anh làm đủ nghề để nuôi nhỏ em ăn học. Hôm nay lại đến hạn nộp tiền học phí cho nhỏ em."
	
	ui.play_intro_cutscene(narrator_text, func():
		var q := quests[0]
		ui.show_dialogue(str(q["giver_name"]), str(q["dialogue"]), false)
		
		var choices: Array = []
		choices.append({
			"text": "Dạ con đang cố đi làm thêm đây cô.",
			"callback": func():
				ui.hide_dialogue()
				# Wait a bit then show player reply using dialogue
				ui.show_dialogue("Người anh (Bạn)", "Dạ con đang cố đi làm thêm gom đủ tiền đây cô.", false)
				var inner_choices: Array = []
				inner_choices.append({
					"text": "Bắt đầu làm việc",
					"callback": func():
						ui.hide_dialogue()
						player.input_blocked = false
						ui.show_map_banner(str(_current_map()["name"]), "Đi mua %s giao cho %s." % [q["products"].keys()[0], q["delivery"]])
						quest_accepted = true
						_refresh_ui()
				})
				ui.show_choices(inner_choices)
		})
		ui.show_choices(choices)
	)'''

if intro_old not in text:
    print("intro old not found, maybe it's not there at all?")

text = text.replace(intro_old, '''func _intro_sequence() -> void:
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
				# Wait a bit then show player reply using dialogue
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
	)''')


with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Updated QUEST_TEMPLATES successfully.")
