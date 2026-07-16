from PIL import Image
import sys

def remove_background(path):
    img = Image.open(path).convert("RGBA")
    datas = img.getdata()
    
    new_data = []
    # If the pixel is very bright (white/light gray) or very dark (black/dark gray) on the edges, but wait...
    # The best way is to assume the top-left pixel is the background color.
    bg_color = datas[0]
    
    for item in datas:
        # Check if the pixel is close to the background color
        if abs(item[0] - bg_color[0]) < 30 and abs(item[1] - bg_color[1]) < 30 and abs(item[2] - bg_color[2]) < 30:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    img.save(path, "PNG")

remove_background("assets/player_boat.png")
print("Background removed.")
