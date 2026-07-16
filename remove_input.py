import os

scripts = [
    "delivery_point.gd",
    "merchant_boat.gd",
    "quest_board.gd",
    "scenic_spot.gd",
    "upgrade_dock.gd"
]

for script in scripts:
    path = os.path.join("scripts", script)
    if not os.path.exists(path):
        continue
    
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    new_lines = []
    skip = False
    for line in lines:
        if "input_event.connect(_on_input_event)" in line or "input_pickable = true" in line:
            continue
        if "func _on_input_event(" in line:
            skip = True
            continue
        if skip:
            if line.startswith("func ") or line.startswith("var "):
                skip = False
            else:
                continue
        if not skip:
            new_lines.append(line)
            
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)
        
print("Removed old input_event from 5 scripts.")
