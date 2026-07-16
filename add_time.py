import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# Add variables at the top
var_block = """
var game_time_minutes: float = 465.0 # Bắt đầu 7:45 AM
var current_day: int = 1
var is_time_running: bool = true
"""
text = text.replace("var quest_accepted: bool = false", "var quest_accepted: bool = false\n" + var_block)

# Add logic to _process
process_old = """func _process(delta: float) -> void:
	if _hold_target != null and is_instance_valid(_hold_target):"""

process_new = """func _process(delta: float) -> void:
	if is_time_running:
		game_time_minutes += delta * 15.0
		if game_time_minutes >= 1440.0:
			game_time_minutes -= 1440.0
			current_day += 1
		var h: int = int(game_time_minutes) / 60
		var m: int = int(game_time_minutes) % 60
		if ui != null and ui.has_method("update_time_ui"):
			ui.update_time_ui(current_day, h, m)
			
		_process_quest_cooldowns(delta)
		
		if money >= 2000000 / 1000: # 2 million VND
			_st.call("change_scene", "res://scenes/WinScreen.tscn")
			is_time_running = false
		elif current_day > 7:
			_st.call("change_scene", "res://scenes/BadEnding.tscn")
			is_time_running = false

	if _hold_target != null and is_instance_valid(_hold_target):"""

text = text.replace(process_old, process_new)

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Time logic added.")
