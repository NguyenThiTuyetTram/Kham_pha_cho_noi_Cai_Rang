from PIL import Image

def resize_and_remove_bg():
    # Load original to get dimensions
    orig = Image.open("assets/player_boat.png")
    target_size = orig.size
    print("Original size:", target_size)
    
    # Load the new white-background image
    new_img_path = r"C:\Users\VITUS\.gemini\antigravity\brain\4b839743-2cd8-43de-9969-71bdd4ef9e12\player_boat_solid_white_1784175658560.png"
    new_img = Image.open(new_img_path).convert("RGBA")
    
    # Resize new image to original dimensions
    # First, let's just scale the new image to fit the target width while maintaining aspect ratio,
    # or just stretch it if they are close. Usually they are squares.
    new_img = new_img.resize(target_size, Image.Resampling.LANCZOS)
    
    # Remove white background
    datas = new_img.getdata()
    new_data = []
    
    # Check top-left pixel for background color
    bg = datas[0]
    
    for item in datas:
        # If the pixel is close to the background color (usually white)
        if abs(item[0] - bg[0]) < 40 and abs(item[1] - bg[1]) < 40 and abs(item[2] - bg[2]) < 40:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
            
    new_img.putdata(new_data)
    new_img.save("assets/player_boat_new.png", "PNG")
    print("Saved as assets/player_boat_new.png")

if __name__ == "__main__":
    resize_and_remove_bg()
