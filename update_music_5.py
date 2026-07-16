import re

with open('scripts/scene_transition.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r'bgm_game = load\("res://[^"]+\.mp3"\)', 'bgm_game = load("res://bgm_hanh_trinh_tren_dat_phu_sa.mp3")', text)

with open('scripts/scene_transition.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Updated scene_transition.gd")
