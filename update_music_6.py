import re

# Update scene_transition.gd
with open('scripts/scene_transition.gd', 'r', encoding='utf-8') as f:
    text_st = f.read()

text_st = re.sub(r'bgm_game = load\("res://[^"]+\.mp3"\)', 'bgm_game = load("res://bgm_da_co_hoai_lang.mp3")', text_st)

old_logic = """	if scene_path == "res://scenes/Game.tscn":
		play_music(bgm_game)"""
new_logic = """	if scene_path == "res://scenes/Game.tscn":
		music_player.stop()"""
text_st = text_st.replace(old_logic, new_logic)

with open('scripts/scene_transition.gd', 'w', encoding='utf-8') as f:
    f.write(text_st)

# Update game_manager.gd
with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text_gm = f.read()

old_gm = """						current_quest = q.duplicate()
						quest_accepted = true"""
new_gm = """						current_quest = q.duplicate()
						quest_accepted = true
						SceneTransition.play_music(SceneTransition.bgm_game)"""
text_gm = text_gm.replace(old_gm, new_gm)

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text_gm)

print("Updated scene_transition.gd and game_manager.gd")
