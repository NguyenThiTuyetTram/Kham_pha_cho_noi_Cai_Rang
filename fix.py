import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('"Tiệm Anh Đèn"', '"Tiệm Ánh Đèn"')

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Done")
