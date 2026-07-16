import re

with open('scripts/scene_transition.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# We replace whatever the game music is with bgm_huong_toc_ma_non.mp3
text = re.sub(r'bgm_game = load\("res://[^"]+\.mp3"\)', 'bgm_game = load("res://bgm_huong_toc_ma_non.mp3")', text)

with open('scripts/scene_transition.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Updated scene_transition.gd")
