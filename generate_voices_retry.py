import os
import time

lines = [
    ("intro_teacher.mp3", "vi-VN-HoaiMyNeural", "Tuần sau là hạn chót nộp học phí cho bé Hà rồi, chắc là không hoãn được nữa đâu con à. Cô cũng biết hoàn cảnh 2 anh em khó khăn nhưng bé học rất tốt nếu dừng học ngay bây giờ thì tội cho nó lắm. Con cầm đỡ 500 ngàn tiền vốn, chịu khó đi lấy trái cây giao cho người ta để kiếm thêm tiền lời. Cố gắng xoay sở 2 triệu cho Hà được đi học tiếp."),
    ("merchant_anhhai.mp3", "vi-VN-NamMinhNeural", "Trái cây miệt vườn mới hái! 55 ngàn một giỏ. Mua mở hàng cho chú đi con."),
    ("merchant_diba.mp3", "vi-VN-HoaiMyNeural", "Bún riêu nóng hổi vừa thổi vừa ăn đây! 45 ngàn một tô. Ghé vô con ơi."),
    ("quest_1.mp3", "vi-VN-NamMinhNeural", "Đêm nay khách đông, em gom giúp 3 giỏ trái cây rồi giao cho Tiệm Ánh Đèn. Chú ứng trước cho 250 ngàn tiền công và tiền hàng, nhớ ép được giá rẻ thì phần dư con cứ bỏ túi."),
    ("quest_3.mp3", "vi-VN-HoaiMyNeural", "Đi Kênh Vườn Trái Cây, gom 4 giỏ trái cây mang về Nhà Vườn Chín Ngọt. Tiền công 350 ngàn nè. Cố ép giá mấy sạp thuyền để dư ra chút đỉnh nghen."),
    ("bargain_fail_female.mp3", "vi-VN-HoaiMyNeural", "Trời ơi bớt dữ vậy con! Hàng ngon vậy bán giá đó cô lỗ chết. Đúng giá cô mới bán được nà."),
    ("bargain_perfect_male.mp3", "vi-VN-NamMinhNeural", "Hay quá con trai! Chú nhượng lại giá vốn cho con luôn đó!"),
]

for filename, voice, text in lines:
    filepath = os.path.join("assets", "voice", filename)
    while True:
        if os.path.exists(filepath) and os.path.getsize(filepath) > 0:
            break
        print(f"Generating {filename}...")
        cmd = f'edge-tts --voice {voice} --text "{text}" --write-media "{filepath}"'
        os.system(cmd)
        if os.path.exists(filepath) and os.path.getsize(filepath) > 0:
            break
        time.sleep(1)

print("Done generating retry voices!")
