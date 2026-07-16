import yt_dlp
import imageio_ffmpeg
import os

ffmpeg_path = imageio_ffmpeg.get_ffmpeg_exe()
print("FFmpeg path:", ffmpeg_path)

ydl_opts = {
    'format': 'bestaudio/best',
    'outtmpl': 'bgm_ve_mien_tay.%(ext)s',
    'ffmpeg_location': ffmpeg_path,
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'mp3',
        'preferredquality': '192',
    }],
}

with yt_dlp.YoutubeDL(ydl_opts) as ydl:
    ydl.download(['ytsearch1:Về Miền Tây Tô Thanh Tùng'])
