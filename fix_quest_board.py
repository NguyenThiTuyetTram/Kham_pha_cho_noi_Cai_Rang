import re

with open('scripts/quest_board.gd', 'r', encoding='utf-8') as f:
    text = f.read()

board_old = """	if "available_quests" in scene and scene.available_quests.has("Trạm Điều Phối") and not scene.quest_accepted:"""
board_new = """	var check_name = board_name
	if "available_quests" in scene and scene.available_quests.has(check_name) and not scene.quest_accepted:"""

if board_old in text:
    text = text.replace(board_old, board_new)
    with open('scripts/quest_board.gd', 'w', encoding='utf-8') as f:
        f.write(text)
    print("quest_board updated.")
else:
    # Just in case there is some character mismatch
    text = re.sub(r'if "available_quests" in scene and scene\.available_quests\.has\([^)]+\) and not scene\.quest_accepted:', board_new, text)
    with open('scripts/quest_board.gd', 'w', encoding='utf-8') as f:
        f.write(text)
    print("quest_board updated via regex.")
