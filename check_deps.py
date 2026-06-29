import os
import re

def check():
    # gather all valid res:// paths
    valid_res = set()
    for root, dirs, files in os.walk('.'):
        if '.git' in root or '.godot' in root:
            continue
        for f in files:
            if not f.endswith('.import') and not f.endswith('.uid') and not f.startswith('.'):
                path = os.path.relpath(os.path.join(root, f), '.').replace('\\', '/')
                valid_res.add('res://' + path)
    
    # check inside .tscn and .gd files
    for root, dirs, files in os.walk('.'):
        if '.git' in root or '.godot' in root:
            continue
        for f in files:
            if f.endswith('.tscn') or f.endswith('.gd') or f.endswith('.godot'):
                path = os.path.join(root, f)
                try:
                    with open(path, 'r', encoding='utf-8') as file:
                        content = file.read()
                        matches = re.findall(r'res://[^"\'\s]+', content)
                        for match in matches:
                            # Remove trailing quotes or parenthesis if any slipped in
                            match = match.strip(')"]\'')
                            if match not in valid_res:
                                print(f"File {path} has broken dependency: {match}")
                except Exception as e:
                    pass

check()
