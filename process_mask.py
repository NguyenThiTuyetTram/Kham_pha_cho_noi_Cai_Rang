from PIL import Image
import os

def process(f):
    if not os.path.exists(f):
        print("Not found", f)
        return
    img = Image.open(f).convert('RGBA')
    d = img.getdata()
    new_d = [(255,255,255,255) if r>200 and g>200 and b<100 else (0,0,0,0) for r,g,b,a in d]
    img.putdata(new_d)
    img.save(f)
    print("Saved", f)

process('river_market_background_bo_song_overlay_v2.png')
process('map_orchard_canals_bo_song_overlay.png')
