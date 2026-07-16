import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix active_quest logic again
active_quest_old = """func _active_quest() -> Dictionary:
	return quests[min(active_quest, quests.size() - 1)] as Dictionary"""
active_quest_new = """func _active_quest() -> Dictionary:
	return current_quest"""

if active_quest_old in text:
    text = text.replace(active_quest_old, active_quest_new)
else:
    # It might already be replaced, let's find it.
    pass

# Replace entire accept_quest func
accept_old = """func accept_quest(board: Area2D) -> void:
	var quest: Dictionary = _active_quest()
	var board_id: String = str(board.get("board_id"))
	if quest_accepted:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Bạn đang theo hợp đồng hiện tại")
		return
	if quest.get("giver", "") != board_id:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Hợp đồng hiện tại không nhận ở đây")
		return
	quest_accepted = true
	board.call("accept_feedback")
	_st.call("play_success_sfx")
	player.shake(0.15, 3.0)
	ui.show_map_banner(str(_current_map()["name"]), "Đã nhận: %s" % quest["title"])
	ui.show_dialogue(str(quest["giver_name"]), str(quest.get("dialogue", "Nhận hợp đồng rồi nhé, đi đúng tuyến và quay lại khi hoàn tất.")))
	_refresh_ui()"""

accept_new = """func accept_quest(giver_node: Area2D) -> void:
	var giver_name: String = str(giver_node.get("merchant_name")) if giver_node.get("merchant_name") else ""
	if giver_name == "" and giver_node.get("board_name"):
		giver_name = str(giver_node.get("board_name"))
		if giver_name == "Trạm Điều Phối Cái Răng":
			giver_name = "Trạm Điều Phối"
	
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
	_st.call("play_success_sfx")
	player.shake(0.15, 3.0)
	ui.show_map_banner(str(_current_map()["name"]), "Đã nhận: %s" % current_quest["title"])
	ui.show_dialogue(str(current_quest.get("giver_name", "Nhiệm vụ")), str(current_quest.get("dialogue", "Nhận đơn hàng mới.")), true)
	_refresh_ui()"""

if accept_old in text:
    text = text.replace(accept_old, accept_new)
else:
    print("accept_old not found!")

# Replace advance_quest func
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

if advance_old in text:
    text = text.replace(advance_old, advance_new)
else:
    print("advance_old not found!")

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Quest funcs updated successfully.")
