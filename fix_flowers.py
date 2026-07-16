with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

replacements = {
    '"Hoa tươi"': '"Trái cây"',
    '2 bó hoa tươi': '2 giỏ trái cây',
    '2 bó hoa': '2 giỏ trái cây',
    '2 hoa tươi': '2 giỏ trái cây',
}

for old, new in replacements.items():
    text = text.replace(old, new)

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Done replacing flowers with fruits.")
