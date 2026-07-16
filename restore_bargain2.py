import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

bargain_new = """func _negotiate_bargain(merchant: Area2D, original_price: int, bargain_price: int) -> void:
	var merchant_name: String = str(merchant.get("merchant_name"))
	ui.hide_dialogue()
	
	ui.start_bargain(func(success: bool):
		if success:
			var success_msg := "Thôi coi như bán mở hàng lấy thảo, cô bớt cho con còn %dk đó. Lấy nghen?" % bargain_price
			ui.show_dialogue(merchant_name, success_msg, false)
			
			var choices: Array = []
			choices.append({
				"text": "Dạ chốt mua! (%dk)" % bargain_price,
				"callback": func():
					_execute_purchase(merchant, bargain_price)
			})
			choices.append({
				"text": "Thôi con không mua nữa",
				"callback": func():
					_cancel_purchase_with_sulk(merchant)
			})
			ui.show_choices(choices)
		else:
			_st.call("play_fail_sfx")
			var fail_msg := "Trời ơi bớt dữ vậy con! Hàng ngon vậy bán giá đó cô lỗ chết. Đúng %dk cô mới bán được nè." % original_price
			ui.show_dialogue(merchant_name, fail_msg, false)
			
			var choices: Array = []
			choices.append({
				"text": "Dạ thôi con mua đúng giá (%dk)" % original_price,
				"callback": func():
					_execute_purchase(merchant, original_price)
			})
			choices.append({
				"text": "Thôi vậy con không mua nữa",
				"callback": func():
					_cancel_purchase_with_sulk(merchant)
			})
			ui.show_choices(choices)
	)
"""

text = re.sub(r"func _negotiate_bargain\(merchant: Area2D, original_price: int, bargain_price: int\) -> void:.*?func _cancel_purchase_polite", bargain_new + "\n\nfunc _cancel_purchase_polite", text, flags=re.DOTALL)

with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
    f.write(text)
print("Bargain minigame logic restored.")
