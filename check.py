with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

points = [
    "Dãy Nhà Ven Sông",
    "Bến Du Lịch",
    "Nhà Vườn Chín Ngọt",
    "Sân Khấu Thủy Đình",
    "Đền Lồng Khổng Lồ"
]
with open('out.txt', 'w', encoding='utf-8') as f:
    for p in points:
        f.write(f'{p}: {text.count(p)}\n')
