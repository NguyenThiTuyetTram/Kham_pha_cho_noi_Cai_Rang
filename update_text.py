with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

old_text = 'Ở gần khu chợ nổi Cái Răng có hai anh em mồ côi cha mẹ. Người anh làm đủ nghề để nuôi nhỏ em ăn học. Hôm nay lại đến hạn nộp tiền học phí 2 triệu cho nhỏ em.'
new_text = 'Từ bận tía má đi mãi không về, gánh nặng gia đình đổ dồn lên vai hai anh em mồ côi. Giữa chợ nổi mênh mông bọt bèo, người anh quyết không để tương lai của bé Hà phải chìm lấp trong cái chữ mờ phai. Hôm nay lại đến hạn, phải ráng gom bằng được 2 triệu tiền học cho em!'

if old_text in text:
    text = text.replace(old_text, new_text)
    with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Done")
else:
    print("Old text not found.")
