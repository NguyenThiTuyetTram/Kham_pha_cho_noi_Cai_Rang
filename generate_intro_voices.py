import os
import time

lines = [
    ("narrator_intro.mp3", "vi-VN-NamMinhNeural", "Ở gần khu chợ nổi Cái Răng có hai anh em mồ côi cha mẹ. Người anh làm đủ nghề để nuôi nhỏ em ăn học. Hôm nay lại đến hạn nộp tiền học phí cho nhỏ em."),
    ("intro_player.mp3", "vi-VN-NamMinhNeural", "Dạ con đang cố đi làm thêm gom đủ tiền đây cô.")
]

for filename, voice, text in lines:
    filepath = os.path.join("assets", "voice", filename)
    while True:
        if os.path.exists(filepath):
            os.remove(filepath)
        print(f"Generating {filename}...")
        cmd = f'edge-tts --voice {voice} --text "{text}" --write-media "{filepath}"'
        os.system(cmd)
        if os.path.exists(filepath) and os.path.getsize(filepath) > 0:
            break
        time.sleep(1)

print("Done generating intro voices!")
