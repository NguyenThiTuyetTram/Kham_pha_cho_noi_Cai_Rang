import re

with open('scripts/game_manager.gd', 'r', encoding='utf-8') as f:
    text = f.read()

bargain_old = """func _negotiate_bargain(merchant: Area2D, original_price: int, bargain_price: int) -> void:
	var merchant_name: String = str(merchant.get("merchant_name"))
	
	var base_chance := 0.5
	var total_chance := base_chance + (reputation * 0.08)
	var is_success := randf() < total_chance
	
	if is_success:
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
		ui.show_choices(choices)"""

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
	)"""

if bargain_old in text:
    text = text.replace(bargain_old, bargain_new)
    with open('scripts/game_manager.gd', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Bargain minigame logic restored.")
else:
    print("bargain_old NOT FOUND!")
