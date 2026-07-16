import yt_dlp
import imageio_ffmpeg
import os
import time

ffmpeg_path = imageio_ffmpeg.get_ffmpeg_exe()
print("FFmpeg path:", ffmpeg_path)

ydl_opts = {
    'format': 'bestaudio/best',
    'outtmpl': 'bgm_hanh_trinh_tren_dat_phu_sa.%(ext)s',
    'ffmpeg_location': ffmpeg_path,
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'mp3',
        'preferredquality': '192',
    }],
    'retries': 20,
    'fragment_retries': 20,
}

success = False
while not success:
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download(['ytsearch1:Hành Trình Trên Đất Phù Sa hòa tấu không lời'])
        success = True
    except Exception as e:
        print("Download failed, retrying in 5s...", e)
        time.sleep(5)
