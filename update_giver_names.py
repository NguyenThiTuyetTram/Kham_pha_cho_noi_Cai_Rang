import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('"giver_name": "Bàn Điều Tour"', '"giver_name": "Bàn Điều Tour Ven Sông"')
text = text.replace('"giver_name": "Hợp Tác Xã"', '"giver_name": "Hợp Tác Xã Nhà Vườn"')
text = text.replace('"giver_name": "Trạm Điều Phối"', '"giver_name": "Trạm Điều Phối Ánh Đèn"')

# Also remove the hacky fix in waypoints since it's no longer needed:
waypoint_old = """				var giver_name = str(board_node.get("merchant_name")) if board_node.get("merchant_name") else str(board_node.get("board_name"))
				if giver_name == "Trạm Điều Phối Cái Răng": giver_name = "Trạm Điều Phối"
				if available_quests.has(giver_name):"""

waypoint_new = """				var giver_name = str(board_node.get("merchant_name")) if board_node.get("merchant_name") else str(board_node.get("board_name"))
				if available_quests.has(giver_name):"""
text = text.replace(waypoint_old, waypoint_new)

# And in accept_quest
accept_old = """	var giver_name: String = str(giver_node.get("merchant_name")) if giver_node.get("merchant_name") else ""
	if giver_name == "" and giver_node.get("board_name"):
		giver_name = str(giver_node.get("board_name"))
		if giver_name == "Trạm Điều Phối Cái Răng":
			giver_name = "Trạm Điều Phối\""""

accept_new = """	var giver_name: String = str(giver_node.get("merchant_name")) if giver_node.get("merchant_name") else ""
	if giver_name == "" and giver_node.get("board_name"):
		giver_name = str(giver_node.get("board_name"))"""
text = text.replace(accept_old, accept_new)

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Names updated.")
