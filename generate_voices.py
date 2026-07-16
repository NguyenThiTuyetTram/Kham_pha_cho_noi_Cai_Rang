import os
import asyncio

lines = [
    ("intro_teacher.mp3", "vi-VN-HoaiMyNeural", "Tuần sau là hạn chót nộp học phí cho bé Hà rồi, chắc là không hoãn được nữa đâu con à. Cô cũng biết hoàn cảnh 2 anh em khó khăn nhưng bé học rất tốt nếu dừng học ngay bây giờ thì tội cho nó lắm. Con cầm đỡ 500 ngàn tiền vốn, chịu khó đi lấy trái cây giao cho người ta để kiếm thêm tiền lời. Cố gắng xoay sở 2 triệu cho Hà được đi học tiếp."),
    ("intro_player.mp3", "vi-VN-NamMinhNeural", "Dạ con đang cố chạy việc ở bên chợ nổi cái răng để kiếm đủ tiền."),
    ("merchant_ditu.mp3", "vi-VN-HoaiMyNeural", "Con trai ngoan đi mua đồ hả? Bánh dân gian nay ngon lắm, giá gốc 90 ngàn một hộp nhen con."),
    ("merchant_chubay.mp3", "vi-VN-NamMinhNeural", "Nước dừa tươi rói đây! Giá 70 ngàn một trái, mua mau kẻo hết con trai."),
    ("merchant_anhhai.mp3", "vi-VN-NamMinhNeural", "Trái cây miệt vườn mới hái! 55 ngàn một giỏ. Mua mở hàng cho chú đi con."),
    ("merchant_diba.mp3", "vi-VN-HoaiMyNeural", "Bún riêu nóng hổi vừa thổi vừa ăn đây! 45 ngàn một tô. Ghé vô con ơi."),
    ("quest_1.mp3", "vi-VN-NamMinhNeural", "Đêm nay khách đông, em gom giúp 3 giỏ trái cây rồi giao cho Tiệm Ánh Đèn. Chú ứng trước cho 250 ngàn tiền công và tiền hàng, nhớ ép được giá rẻ thì phần dư con cứ bỏ túi."),
    ("quest_2.mp3", "vi-VN-NamMinhNeural", "Khách sắp xuống bến. Mua dùm chú 2 trái nước dừa và 1 hộp bánh dân gian giao bến du lịch. Tiền công và tiền hàng chú gửi 300 ngàn, ráng trả giá khéo để có lời nha con."),
    ("quest_3.mp3", "vi-VN-HoaiMyNeural", "Đi Kênh Vườn Trái Cây, gom 4 giỏ trái cây mang về Nhà Vườn Chín Ngọt. Tiền công 350 ngàn nè. Cố ép giá mấy sạp thuyền để dư ra chút đỉnh nghen."),
    ("bargain_fail_female.mp3", "vi-VN-HoaiMyNeural", "Trời ơi bớt dữ vậy con! Hàng ngon vậy bán giá đó cô lỗ chết. Đúng giá cô mới bán được nà."),
    ("bargain_fail_male.mp3", "vi-VN-NamMinhNeural", "Ép giá chú quá con ơi! Mua đúng giá đi, mai mốt chú bớt cho."),
    ("bargain_good_female.mp3", "vi-VN-HoaiMyNeural", "Thôi coi như bán mở hàng lấy thảo, cô bớt cho con chút đỉnh đó. Lấy nghen?"),
    ("bargain_good_male.mp3", "vi-VN-NamMinhNeural", "Thấy con ngoan chú bớt cho đó. Chốt đơn nghen?"),
    ("bargain_perfect_female.mp3", "vi-VN-HoaiMyNeural", "Mắt con lẹ quá trời! Thôi nể con, cô để giá gốc sát rạt luôn đó!"),
    ("bargain_perfect_male.mp3", "vi-VN-NamMinhNeural", "Hay quá con trai! Chú nhượng lại giá vốn cho con luôn đó!"),
    ("delivery_success.mp3", "vi-VN-HoaiMyNeural", "Cảm ơn con nhen. Hàng tươi lắm, tiền công của con đây. Đi đường cẩn thận nha."),
    ("not_enough_money.mp3", "vi-VN-HoaiMyNeural", "Ủa tiền đâu con ơi? Kiếm thêm tiền rồi quay lại ghe nghen!"),
]

for filename, voice, text in lines:
    filepath = os.path.join("assets", "voice", filename)
    cmd = f'edge-tts --voice {voice} --text "{text}" --write-media "{filepath}"'
    print(f"Generating {filename}...")
    os.system(cmd)

print("Done generating voices!")
