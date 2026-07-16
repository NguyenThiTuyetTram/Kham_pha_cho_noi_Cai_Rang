import re

with open('scripts/scene_transition.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r'bgm_game = load\("res://[^"]+\.mp3"\)', 'bgm_game = load("res://bgm_chiec_ao_ba_ba.mp3")', text)

with open('scripts/scene_transition.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Updated scene_transition.gd")
