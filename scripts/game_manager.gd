extends Node2D

const STARTING_MONEY: int = 650
const WORLD_SCALE: float = 1.6

var money: int = STARTING_MONEY
var reputation: int = 0
var active_quest: int = 0
var cargo: Dictionary = {}
var discovered_spots: Dictionary = {}
var engine_level: int = 1
var current_map_id: String = "cai_rang"
var quest_accepted: bool = false

var ui: CanvasLayer
var player: CharacterBody2D
var background: Sprite2D
var water_ripple_layer: Node2D
var decoration_layer: Node2D
var maps: Dictionary = {}
@onready var _st: Node = get_node("/root/SceneTransition")

var _hold_target: Node2D = null
var _hold_timer: float = 0.0
const HOLD_DURATION: float = 0.30
var _interact_groups: Dictionary = {
	"merchant_boat": "buy_from_merchant",
	"quest_hub": "accept_quest",
	"delivery_point": "complete_delivery",
	"scenic_spot": "discover_spot",
	"river_portal": "use_portal",
	"upgrade_dock": "buy_engine_upgrade"
}

var quests: Array[Dictionary] = [
	{
		"title": "Đơn hàng mở chợ",
		"description": "Mua 3 giỏ trái cây ở Cái Răng và giao cho Tiệm Ánh Đèn.",
		"map": "cai_rang",
		"giver": "cai_rang_dispatch",
		"giver_name": "Trạm Điều Phối Ánh Đèn",
		"dialogue": "Đêm nay khách đông, em gom giúp 3 giỏ trái cây rồi giao cho Tiệm Ánh Đèn. Đi chậm qua khúc nước đông để khỏi va bến.",
		"products": {"Trái cây": 3},
		"delivery": "Tiệm Ánh Đèn",
		"reward": 150,
		"rep": 1
	},
	{
		"title": "Tour đêm Bến Ninh Kiều",
		"description": "Sang Bến Ninh Kiều và check-in 2 điểm sáng ven sông.",
		"map": "ninh_kieu",
		"giver": "ninh_kieu_pr",
		"giver_name": "Quầy PR Du Lịch Đêm",
		"dialogue": "Bến Ninh Kiều cần vài góc ảnh đẹp để quảng bá tour đêm. Ghé hai điểm sáng ven sông, chụp cho rõ bảng đèn và bến tàu.",
		"spots": ["ninh_kieu_prom", "ninh_kieu_wharf"],
		"reward": 120,
		"rep": 2
	},
	{
		"title": "Đặc sản cho du khách",
		"description": "Ở Bến Ninh Kiều, chuẩn bị 2 nước dừa và 1 bánh dân gian cho Bến Du Lịch.",
		"map": "ninh_kieu",
		"giver": "ninh_kieu_tour",
		"giver_name": "Bàn Điều Tour Ven Sông",
		"dialogue": "Đoàn khách sắp xuống bến. Chuẩn bị nước dừa và bánh dân gian, ưu tiên mua ở sạp gần bến để giữ đồ còn tươi.",
		"products": {"Nước dừa": 2, "Bánh dân gian": 1},
		"delivery": "Bến Du Lịch",
		"reward": 240,
		"rep": 2
	},
	{
		"title": "Thu hoạch trong kênh vườn",
		"description": "Đi Kênh Vườn Trái Cây, mua 4 trái cây và giao cho Nhà Vườn Chín Ngọt.",
		"map": "orchard",
		"giver": "orchard_coop",
		"giver_name": "Hợp Tác Xã Nhà Vườn",
		"dialogue": "Nhà vườn vừa hái xong mẻ trái cây mới. Lấy đủ 4 phần rồi giao về bến Chín Ngọt trước khi chuyến gom hàng rời kênh.",
		"products": {"Trái cây": 4},
		"delivery": "Nhà Vườn Chín Ngọt",
		"reward": 260,
		"rep": 2
	},
	{
		"title": "Ánh đèn làng nghề",
		"description": "Ghé Làng Đèn Lồng và chụp 2 điểm trang trí cho chiến dịch PR.",
		"map": "lantern",
		"giver": "lantern_workshop",
		"giver_name": "Xưởng Sáng Tạo Đèn Lồng",
		"dialogue": "Làng đèn đang lên màu đẹp nhất. Chụp hai điểm trang trí để đội truyền thông dùng cho poster đêm hội.",
		"spots": ["lantern_arch", "lantern_temple"],
		"reward": 180,
		"rep": 3
	},
	{
		"title": "Đêm hội Cái Răng",
		"description": "Gom 2 trái cây, 2 nước dừa, 2 bánh dân gian và giao cho Sân Khấu Nổi.",
		"map": "lantern",
		"giver": "festival_stage_office",
		"giver_name": "Ban Tổ Chức Đêm Hội",
		"dialogue": "Đây là chuyến cuối: gom đủ quà miền Tây cho sân khấu nổi. Nếu làm gọn, cả khu chợ sẽ sáng đèn đúng giờ.",
		"products": {"Trái cây": 2, "Nước dừa": 2, "Bánh dân gian": 2},
		"delivery": "Sân Khấu Nổi",
		"reward": 420,
		"rep": 4
	}
]

func _ready() -> void:
	ui = $UI
	player = $PlayerBoat
	background = $RiverMarketBackground
	water_ripple_layer = $WaterRippleLayer
	decoration_layer = $DecorationLayer
	background.z_index = -20
	
	_build_maps()
	_configure_world()
	_apply_map("cai_rang", Vector2(960, 760))
	_refresh_ui()
	ui.show_map_banner(str(_current_map()["name"]), "Tìm điểm nhận nhiệm vụ để bắt đầu hợp đồng đầu tiên.")


func _unhandled_input(event: InputEvent) -> void:
	if player.input_blocked or ui.dialogue_panel.visible:
		_hold_target = null
		_hold_timer = 0.0
		ui.hide_interact_progress()
		return

	var target := _get_nearest_interactable()

	if event.is_action_pressed("interact"):
		if target != null:
			_hold_target = target
			_hold_timer = 0.0
			ui.show_interact_progress(0.0)
		else:
			_hold_target = null
			_hold_timer = 0.0
			ui.hide_interact_progress()

	elif event.is_action_released("interact"):
		_hold_target = null
		_hold_timer = 0.0
		ui.hide_interact_progress()


func _process(delta: float) -> void:
	if _hold_target != null and is_instance_valid(_hold_target):
		if not bool(_hold_target.get("player_near")):
			_hold_target = null
			_hold_timer = 0.0
			ui.hide_interact_progress()
			return

		_hold_timer += delta
		var progress := clampf(_hold_timer / HOLD_DURATION, 0.0, 1.0)
		ui.show_interact_progress(progress)

		if _hold_timer >= HOLD_DURATION:
			var target := _hold_target
			var group := _get_interact_group(target)
			_hold_target = null
			_hold_timer = 0.0
			ui.hide_interact_progress()

			if group != null and _interact_groups.has(group):
				var method_name: String = _interact_groups[group]
				if has_method(method_name):
					call(method_name, target)
				elif target.has_method(method_name):
					target.call(method_name)
				get_viewport().set_input_as_handled()
	elif _hold_timer > 0.0:
		_hold_timer = 0.0
		ui.hide_interact_progress()


func _get_nearest_interactable() -> Node2D:
	if player == null:
		return null
	var best_node: Node2D = null
	var best_distance: float = INF
	for group in _interact_groups.keys():
		for candidate in get_tree().get_nodes_in_group(group):
			if not candidate is Node2D:
				continue
			var interactable := candidate as Node2D
			if not interactable.visible or not bool(interactable.get("player_near")):
				continue
			var distance: float = player.global_position.distance_squared_to(interactable.global_position)
			if distance < best_distance:
				best_distance = distance
				best_node = interactable
	return best_node


func _get_interact_group(node: Node2D) -> String:
	for group in _interact_groups.keys():
		if node.is_in_group(group):
			return group
	return ""


func use_portal(portal: Node2D) -> void:
	var target_map: String = str(portal.get("target_map_id"))
	var spawn_val = portal.get("target_spawn")
	var target_spawn: Vector2 = spawn_val if spawn_val != null else Vector2.ZERO
	if target_map.is_empty():
		return
	change_map(target_map, target_spawn)


func change_map(map_id: String, spawn_position: Vector2) -> void:
	if not maps.has(map_id):
		return
	current_map_id = map_id
	_apply_map(map_id, spawn_position)
	_refresh_ui()
	ui.show_map_banner(str(_current_map()["name"]), _map_tip())
	
	_apply_currents(_current_map().get("currents", []) as Array)

func accept_quest(board: Area2D) -> void:
	var quest: Dictionary = _active_quest()
	var board_id: String = str(board.get("board_id"))
	if quest_accepted:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Bạn đang theo hợp đồng hiện tại")
		return
	if quest.get("giver", "") != board_id:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Hợp đồng hiện tại không nhận ở đây")
		return
	quest_accepted = true
	board.call("accept_feedback")
	_st.call("play_success_sfx")
	player.shake(0.15, 3.0)
	ui.show_map_banner(str(_current_map()["name"]), "Đã nhận: %s" % quest["title"])
	ui.show_dialogue(str(quest["giver_name"]), str(quest.get("dialogue", "Nhận hợp đồng rồi nhé, đi đúng tuyến và quay lại khi hoàn tất.")))
	_refresh_ui()


func buy_from_merchant(merchant: Area2D) -> void:
	var product_name: String = str(merchant.get("product_name"))
	var merchant_name: String = str(merchant.get("merchant_name"))
	var price: int = int(merchant.get("price"))
	var stock: int = int(merchant.get("stock"))
	
	if stock <= 0:
		ui.flash_prompt("%s đã hết hàng" % merchant_name)
		return

	# Block player input
	player.input_blocked = true
	
	# Check if merchant is sulking
	var is_sulking: bool = bool(merchant.get("is_sulking"))
	if is_sulking:
		var sulk_pitch := "Nè, mua thì mua đúng giá %dk nghe con. Hồi nãy trả giá đã đời rồi bỏ đi cô còn giận á!" % price
		ui.show_dialogue(merchant_name, sulk_pitch, false)
		
		var choices: Array = []
		choices.append({
			"text": "Dạ thôi con mua đúng giá (%dk)" % price,
			"callback": func():
				merchant.set("is_sulking", false)
				_execute_purchase(merchant, price)
		})
		choices.append({
			"text": "Thôi con không mua nữa",
			"callback": func():
				_cancel_purchase_sulky_dismissal(merchant_name)
		})
		ui.show_choices(choices)
		return
		
	var pitch := ""
	match product_name:
		"Trái cây":
			pitch = "Cô có trái cây tươi rói mới hái ngoài vườn nè con, lấy một giỏ %dk nghen?" % price
		"Nước dừa":
			pitch = "Dừa xiêm ngọt lịm mới chặt đây con ơi, uống một trái %dk cho mát nghen?" % price
		"Bánh dân gian":
			pitch = "Bánh dân gian nóng hổi thơm phức của dì đây, chỉ %dk thôi nè con." % price
		_:
			pitch = "Ghe cô bán %s ngon lắm nè, ủng hộ cô một phần %dk nghen?" % [product_name, price]
			
	ui.show_dialogue(merchant_name, pitch, false)
	
	var choices: Array = []
	choices.append({
		"text": "Mua đúng giá (%dk)" % price,
		"callback": func():
			_execute_purchase(merchant, price)
	})
	
	# Bargaining price: reduce by about 15-20%
	var bargain_price := int(price * 0.8 / 5) * 5
	if bargain_price >= price:
		bargain_price = price - 10
	if bargain_price < 10:
		bargain_price = int(price * 0.8)
		
	choices.append({
		"text": "Trả giá còn %dk" % bargain_price,
		"callback": func():
			_negotiate_bargain(merchant, price, bargain_price)
	})
	
	choices.append({
		"text": "Thôi con chưa mua",
		"callback": func():
			_cancel_purchase_polite(merchant_name)
	})
	
	ui.show_choices(choices)


func _execute_purchase(merchant: Area2D, final_price: int) -> void:
	var product_name: String = str(merchant.get("product_name"))
	var merchant_name: String = str(merchant.get("merchant_name"))
	var stock: int = int(merchant.get("stock"))
	
	if money < final_price:
		_st.call("play_fail_sfx")
		ui.show_dialogue(merchant_name, "Ủa tiền đâu con ơi? Kiếm thêm tiền rồi quay lại ghe cô nghen!", true)
		player.input_blocked = false
		return
		
	money -= final_price
	stock -= 1
	merchant.set("stock", stock)
	cargo[product_name] = get_cargo_count(product_name) + 1
	merchant.call("purchase_feedback")
	
	_st.call("play_success_sfx")
	var thank_you := "Cảm ơn con nhiều nghen! Ghe cô lúc nào cũng tươi ngon hết á."
	ui.show_dialogue(merchant_name, thank_you, true)
	ui.flash_prompt("Đã mua %s với giá %dk" % [product_name, final_price])
	player.animate_cargo_load(cargo, product_name)
	player.shake(0.18, 4.0)
	player.spawn_particles(Color(0.38, 1.0, 0.55), 6)
	_refresh_ui()
	player.input_blocked = false


func _negotiate_bargain(merchant: Area2D, original_price: int, bargain_price: int) -> void:
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
		var fail_msg := "Trời ơi bớt dữ vậy con! Hàng ngon vậy bán giá đó cô lỗ chết. Đúng %dk cô mới bán được nà." % original_price
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


func _cancel_purchase_polite(merchant_name: String) -> void:
	var cancel_msg := "Hẹn gặp lại con lần sau nghen! Ghe qua lúc nào cũng có sẵn đồ ngon."
	ui.show_dialogue(merchant_name, cancel_msg, true)
	player.input_blocked = false


func _cancel_purchase_with_sulk(merchant: Area2D) -> void:
	var merchant_name: String = str(merchant.get("merchant_name"))
	merchant.set("is_sulking", true)
	_st.call("play_fail_sfx")
	var cancel_msg := "Trời ơi, trả giá đã đời rồi hông mua hả con? Đốt phong long vía dữ nha!"
	ui.show_dialogue(merchant_name, cancel_msg, true)
	player.input_blocked = false


func _cancel_purchase_sulky_dismissal(merchant_name: String) -> void:
	_st.call("play_fail_sfx")
	var cancel_msg := "Đi đi, chừng nào mua đúng giá thì nói chuyện với cô!"
	ui.show_dialogue(merchant_name, cancel_msg, true)
	player.input_blocked = false


func complete_delivery(point: Area2D) -> void:
	var quest: Dictionary = _active_quest()
	var point_name: String = str(point.get("point_name"))
	
	print("=== DEBUG DELIVERY ===")
	print("Quest Accepted: ", quest_accepted)
	print("Current Map: ", current_map_id, " | Quest Map: ", quest.get("map"))
	print("Point Name: ", point_name, " | Quest Delivery: ", quest.get("delivery"))
	print("Cargo Dictionary: ", cargo)
	print("Quest Products Required: ", quest.get("products"))
	print("Has Required Products: ", _has_required_products(quest))
	
	if not quest_accepted:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Hãy nhận nhiệm vụ trước tại điểm điều phối")
		return
	if quest.get("map", "") != current_map_id:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Đơn này ở khu vực khác")
		return
	if not quest.has("delivery") or quest["delivery"] != point_name:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Đây chưa phải điểm giao của nhiệm vụ hiện tại")
		return
	if not _has_required_products(quest):
		_st.call("play_fail_sfx")
		ui.flash_prompt("Chưa đủ hàng cho đơn này")
		return

	_consume_required_products(quest)
	player.animate_cargo_unload(cargo, quest.get("products", {}))
	money += int(quest["reward"])
	reputation += int(quest["rep"])
	point.call("delivery_feedback")
	_st.call("play_success_sfx")
	player.shake(0.3, 8.0)
	ui.show_celebration("Giao hàng thành công!", "+%dk   Danh tiếng +%d" % [quest["reward"], quest["rep"]])
	ui.show_reward_popup(int(quest["reward"]), int(quest["rep"]))
	ui.reward_sparkle(Color(1.0, 0.83, 0.43))
	ui.show_dialogue(point_name, "Nhận hàng thành công. Chuyến này làm khu chợ sáng thêm một nhịp rồi!")
	ui.flash_prompt("+%dk, danh tiếng +%d" % [quest["reward"], quest["rep"]])
	_advance_quest()


func discover_spot(spot: Area2D) -> void:
	if not quest_accepted:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Hãy nhận nhiệm vụ trước khi check-in")
		return
	var spot_id: String = str(spot.get("spot_id"))
	var spot_name: String = str(spot.get("spot_name"))
	if discovered_spots.has(spot_id):
		_st.call("play_fail_sfx")
		ui.flash_prompt("Bạn đã check-in điểm này rồi")
		return
	discovered_spots[spot_id] = true
	reputation += 1
	spot.call("discovery_feedback")
	_st.call("play_success_sfx")
	player.shake(0.12, 2.5)
	ui.flash_prompt("Đã chụp ảnh: %s" % spot_name)

	var quest: Dictionary = _active_quest()
	if quest.get("map", "") == current_map_id and quest.has("spots") and _count_quest_spots(quest) >= (quest["spots"] as Array).size():
		money += int(quest["reward"])
		reputation += int(quest["rep"])
		ui.show_reward_popup(int(quest["reward"]), int(quest["rep"]))
		ui.reward_sparkle(Color(0.62, 0.95, 1.0))
		ui.flash_prompt("Hoàn thành quảng bá! +%dk" % quest["reward"])
		ui.show_dialogue(str(quest["giver_name"]), "Ảnh đẹp lắm. Chiến dịch PR tối nay sẽ có chất miền Tây rõ hơn.")
		_advance_quest()
	else:
		_refresh_ui()


func buy_engine_upgrade(dock: Area2D) -> void:
	var cost: int = 180 + (engine_level - 1) * 170
	if engine_level >= 4:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Máy thuyền đã nâng cấp tối đa")
		return
	if money < cost:
		_st.call("play_fail_sfx")
		ui.flash_prompt("Cần %dk để nâng cấp máy" % cost)
		return
	money -= cost
	engine_level += 1
	player.max_speed += 42.0
	player.acceleration += 115.0
	dock.call("upgrade_feedback")
	_st.call("play_success_sfx")
	player.shake(0.25, 7.0)
	ui.flash_prompt("Nâng cấp máy cấp %d" % engine_level)
	_refresh_ui()


func get_cargo_count(product: String) -> int:
	return int(cargo.get(product, 0))


func can_deliver_at(point_name: String) -> bool:
	var quest: Dictionary = _active_quest()
	return quest_accepted and quest.get("map", "") == current_map_id and quest.get("delivery", "") == point_name and _has_required_products(quest)


func get_current_delivery_name() -> String:
	return str(_active_quest().get("delivery", ""))


func show_prompt(text: String) -> void:
	ui.show_prompt(text)


func hide_prompt() -> void:
	ui.hide_prompt()


func _advance_quest() -> void:
	var quest := _active_quest()
	active_quest += 1
	quest_accepted = false
	if active_quest >= quests.size():
		_st.call("change_scene", "res://scenes/WinScreen.tscn")
		return
	ui.show_celebration("Hoàn thành nhiệm vụ!", quest["title"])
	_refresh_ui()


func _active_quest() -> Dictionary:
	return quests[min(active_quest, quests.size() - 1)] as Dictionary


func _current_map() -> Dictionary:
	return maps[current_map_id] as Dictionary


func _has_required_products(quest: Dictionary) -> bool:
	if not quest.has("products"):
		return false
	var products: Dictionary = quest["products"] as Dictionary
	for product in products.keys():
		if get_cargo_count(str(product)) < int(products[product]):
			return false
	return true


func _consume_required_products(quest: Dictionary) -> void:
	var products: Dictionary = quest["products"] as Dictionary
	for product in products.keys():
		var key: String = str(product)
		var new_count: int = get_cargo_count(key) - int(products[product])
		if new_count <= 0:
			cargo.erase(key)
		else:
			cargo[key] = new_count


func _count_quest_spots(quest: Dictionary) -> int:
	if not quest.has("spots"):
		return 0
	var count: int = 0
	var spot_ids: Array = quest["spots"] as Array
	for spot_id in spot_ids:
		if discovered_spots.has(spot_id):
			count += 1
	return count


func _quest_progress_text() -> String:
	var quest: Dictionary = _active_quest()
	var map_name: String = str(maps[str(quest["map"])]["name"])
	if not quest_accepted:
		return "Đến %s nhận nhiệm vụ tại %s" % [map_name, quest["giver_name"]]
	if quest.has("spots"):
		var spot_ids: Array = quest["spots"] as Array
		return "%s | Check-in %d/%d" % [map_name, _count_quest_spots(quest), spot_ids.size()]
	if quest.has("products"):
		var products: Dictionary = quest["products"] as Dictionary
		var parts: PackedStringArray = PackedStringArray()
		for product in products.keys():
			parts.append("%s %d/%d" % [product, get_cargo_count(str(product)), int(products[product])])
		return "%s | %s | Giao: %s" % [map_name, " | ".join(parts), quest["delivery"]]
	return map_name


func _cargo_text() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for product in cargo.keys():
		if int(cargo[product]) > 0:
			parts.append("%s x%d" % [product, int(cargo[product])])
	return "Trống" if parts.is_empty() else ", ".join(parts)


func _refresh_ui() -> void:
	var quest: Dictionary = _active_quest()
	ui.update_stats(money, _cargo_text(), reputation, engine_level, str(_current_map()["name"]))
	var state: String = "Đang làm" if quest_accepted else "Chưa nhận"
	ui.set_mission("[%s] %s: %s" % [state, quest["title"], quest["description"]])
	ui.set_progress(_quest_progress_text())
	player.sync_cargo_visuals(cargo)
	_update_waypoints()


func _configure_world() -> void:
	player.river_bounds = Rect2(Vector2(150, 115) * WORLD_SCALE, Vector2(1620, 890) * WORLD_SCALE)
	water_ripple_layer.call("set_world_size", Vector2(1920, 1080) * WORLD_SCALE)
	var camera := player.get_node("Camera2D") as Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(1920 * WORLD_SCALE)
	camera.limit_bottom = int(1080 * WORLD_SCALE)


func _apply_map(map_id: String, spawn_position: Vector2) -> void:
	var map: Dictionary = maps[map_id] as Dictionary
	background.texture = load(str(map["background"]))
	background.position = Vector2(960, 540) * WORLD_SCALE
	background.scale = Vector2.ONE * WORLD_SCALE
	player.river_bounds = _scale_rect(map.get("river_bounds", Rect2(Vector2(150, 115), Vector2(1620, 890))) as Rect2)
	player.call("set_water_polygons", _scale_polygons(map.get("water_polygons", []) as Array))
	player.call("reset_safe_position", _to_world(spawn_position))
	player.velocity = Vector2.ZERO
	player.external_force = Vector2.ZERO
	hide_prompt()

	_apply_merchants(map["merchants"] as Array)
	_apply_deliveries(map["deliveries"] as Array)
	_apply_spots(map["spots"] as Array)
	_apply_portals(map["portals"] as Array)
	_apply_currents(map["currents"] as Array)
	_apply_quest_boards(map["quest_boards"] as Array)
	decoration_layer.call("set_decorations", map.get("decorations", []) as Array, WORLD_SCALE)
	water_ripple_layer.call("configure_for_map", map.get("water_style", {}) as Dictionary)
	water_ripple_layer.call("set_current_fields", map["currents"] as Array, WORLD_SCALE)
	_apply_upgrade_dock(map.get("upgrade_dock", {}) as Dictionary)
	
	for child in get_children():
		if child is StaticBody2D and child.name.begins_with("Shore_"):
			child.scale = Vector2.ONE * WORLD_SCALE
			child.collision_layer = 1
			child.collision_mask = 1
			var is_active = (child.name == "Shore_" + map_id)
			for shape in child.get_children():
				if shape is CollisionPolygon2D or shape is CollisionShape2D:
					shape.disabled = !is_active


func _apply_merchants(configs: Array) -> void:
	var nodes: Array = [$MerchantBoatLeft, $MerchantBoatRight, $MerchantBoatBottom, $MerchantBoatTop]
	_apply_area_list(nodes, configs)
	for i in range(nodes.size()):
		var node: Area2D = nodes[i] as Area2D
		if i >= configs.size():
			continue
		var data: Dictionary = configs[i] as Dictionary
		node.set("merchant_name", str(data["name"]))
		node.set("product_name", str(data["product"]))
		node.set("price", int(data["price"]))
		node.set("stock", int(data["stock"]))


func _apply_deliveries(configs: Array) -> void:
	var nodes: Array = [$DeliveryPointShop, $DeliveryPointTour, $DeliveryPointStage]
	_apply_area_list(nodes, configs)
	for i in range(nodes.size()):
		if i < configs.size():
			var data: Dictionary = configs[i] as Dictionary
			nodes[i].set("point_name", str(data["name"]))
			nodes[i].call(
				"setup_visuals",
				(data.get("marker_offset", Vector2.ZERO) as Vector2) * WORLD_SCALE,
				(data.get("npc_offset", Vector2(58, 24)) as Vector2) * WORLD_SCALE,
				(data.get("label_offset", Vector2(-130, -105)) as Vector2) * WORLD_SCALE
			)


func _apply_spots(configs: Array) -> void:
	var nodes: Array = [$ScenicSpotBridge, $ScenicSpotNeonHouses]
	_apply_area_list(nodes, configs)
	for i in range(nodes.size()):
		if i < configs.size():
			var data: Dictionary = configs[i] as Dictionary
			nodes[i].set("spot_id", str(data["id"]))
			nodes[i].set("spot_name", str(data["name"]))


func _apply_portals(configs: Array) -> void:
	var nodes: Array = [$PortalA, $PortalB, $PortalC]
	_apply_area_list(nodes, configs)
	for i in range(nodes.size()):
		if i < configs.size():
			var data: Dictionary = configs[i] as Dictionary
			nodes[i].call("setup", str(data["target"]), data["spawn"] as Vector2, str(data["label"]))


func _apply_currents(configs: Array) -> void:
	var nodes: Array = [$RiverCurrentMid, $RiverCurrentBottom]
	_apply_area_list(nodes, configs)
	for i in range(nodes.size()):
		if i < configs.size():
			var data: Dictionary = configs[i] as Dictionary
			nodes[i].set("current_force", data["force"] as Vector2)


func _apply_quest_boards(configs: Array) -> void:
	var nodes: Array = [$QuestBoardA, $QuestBoardB]
	_apply_area_list(nodes, configs)
	for i in range(nodes.size()):
		if i < configs.size():
			var data: Dictionary = configs[i] as Dictionary
			var visuals: Dictionary = {
				"marker_offset": (data.get("marker_offset", Vector2(76, -72)) as Vector2) * WORLD_SCALE,
				"npc_offset": (data.get("npc_offset", Vector2(-58, -38)) as Vector2) * WORLD_SCALE,
				"boat_offset": (data.get("boat_offset", Vector2.ZERO) as Vector2) * WORLD_SCALE,
				"label_offset": (data.get("label_offset", Vector2(-170, -170)) as Vector2) * WORLD_SCALE
			}
			nodes[i].call("setup", str(data["id"]), str(data["name"]), str(data.get("role", "Nhận hợp đồng")), visuals)


func _apply_upgrade_dock(config: Dictionary) -> void:
	var dock: Area2D = $UpgradeDock
	var enabled: bool = not config.is_empty()
	dock.visible = enabled
	dock.monitoring = enabled
	dock.monitorable = enabled
	if enabled:
		dock.position = _to_world(config["pos"] as Vector2)


func _apply_area_list(nodes: Array, configs: Array) -> void:
	for i in range(nodes.size()):
		var node: Area2D = nodes[i] as Area2D
		if node.has_method("reset_interaction_state"):
			node.call("reset_interaction_state")
		var enabled: bool = i < configs.size()
		node.visible = enabled
		node.monitoring = enabled
		node.monitorable = enabled
		if enabled:
			var data: Dictionary = configs[i] as Dictionary
			node.position = _to_world(data["pos"] as Vector2)
			node.rotation = float(data.get("rot", 0.0))


func _to_world(pos: Vector2) -> Vector2:
	return pos * WORLD_SCALE


func _scale_rect(rect: Rect2) -> Rect2:
	return Rect2(rect.position * WORLD_SCALE, rect.size * WORLD_SCALE)


func _scale_polygons(polygons: Array) -> Array[PackedVector2Array]:
	var scaled: Array[PackedVector2Array] = []
	for polygon_data in polygons:
		var polygon := PackedVector2Array()
		for point in polygon_data:
			polygon.append((point as Vector2) * WORLD_SCALE)
		scaled.append(polygon)
	return scaled


func _update_waypoints() -> void:
	var targets: Array = []
	var quest := _active_quest()
	var quest_map: String = str(quest.get("map", ""))
	var on_quest_map := quest_map == current_map_id

	if not quest_accepted:
		for board_node in get_tree().get_nodes_in_group("quest_hub"):
			if is_instance_valid(board_node) and board_node.visible:
				var board_id: String = str(board_node.get("board_id"))
				var board_name: String = str(board_node.get("board_name"))
				if board_id == quest.get("giver", ""):
					targets.append({"node": board_node, "color": Color(0.2, 0.9, 0.6), "label": board_name})
					break
	elif quest.has("spots") and on_quest_map:
		var spot_ids: Array = quest["spots"] as Array
		for spot_node in get_tree().get_nodes_in_group("scenic_spot"):
			if not is_instance_valid(spot_node) or not spot_node.visible:
				continue
			var sid: String = str(spot_node.get("spot_id"))
			if sid in spot_ids and not discovered_spots.has(sid):
				targets.append({"node": spot_node, "color": Color(0.3, 0.7, 1.0), "label": str(spot_node.get("spot_name"))})
				break
	elif quest.has("products") and on_quest_map:
		var needed := _get_remaining_products(quest)
		if not needed.is_empty():
			for merchant in get_tree().get_nodes_in_group("merchant_boat"):
				if not is_instance_valid(merchant) or not merchant.visible:
					continue
				var prod: String = str(merchant.get("product_name"))
				if prod in needed:
					targets.append({"node": merchant, "color": Color(1.0, 0.72, 0.25), "label": str(merchant.get("merchant_name"))})
					break
		else:
			for delivery in get_tree().get_nodes_in_group("delivery_point"):
				if not is_instance_valid(delivery) or not delivery.visible:
					continue
				var dname: String = str(delivery.get("point_name"))
				if dname == quest.get("delivery", ""):
					targets.append({"node": delivery, "color": Color(0.2, 1.0, 0.4), "label": dname})
					break

	ui.update_waypoints(targets)


func _get_remaining_products(quest: Dictionary) -> Dictionary:
	var needed: Dictionary = {}
	if not quest.has("products"):
		return needed
	var products: Dictionary = quest["products"] as Dictionary
	for product in products.keys():
		var have: int = get_cargo_count(str(product))
		var need: int = int(products[product])
		if have < need:
			needed[product] = need - have
	return needed


func _map_tip() -> String:
	var quest: Dictionary = _active_quest()
	if quest.get("map", "") == current_map_id:
		if quest_accepted:
			return "Hợp đồng hiện tại đang diễn ra ở khu vực này."
		return "Tìm %s để nhận hợp đồng." % quest["giver_name"]
	return "Dùng cổng sông để đến khu vực của hợp đồng hiện tại."


func _build_maps() -> void:
	maps = {
		"cai_rang": {
			"name": "Chợ Nổi Cái Răng",
			"background": "res://assets/river_market_background.png",
			"river_bounds": Rect2(Vector2(0, 115), Vector2(1610, 875)),
			"water_polygons": [
				PackedVector2Array([
					Vector2(0, 990),
					Vector2(0, 830),
					Vector2(70, 760),
					Vector2(115, 700),
					Vector2(190, 660),
					Vector2(95, 620),
					Vector2(165, 570),
					Vector2(120, 520),
					Vector2(185, 470),
					Vector2(180, 420),
					Vector2(260, 360),
					Vector2(330, 300),
					Vector2(390, 240),
					Vector2(430, 160),
					Vector2(470, 120),
					Vector2(1610, 120),
					Vector2(1610, 990)
				])
			],
			"quest_boards": [
				{"pos": Vector2(300, 700), "id": "cai_rang_dispatch", "name": "Trạm Điều Phối Ánh Đèn", "role": "Hợp đồng mở chợ", "boat_offset": Vector2(-18, 10), "npc_offset": Vector2(-20, 20), "marker_offset": Vector2(70, -86), "label_offset": Vector2(-170, -174)}
			],
			"decorations": [
				{"kind": "lantern", "pos": Vector2(318, 610), "phase": 0.2},
				{"kind": "lantern", "pos": Vector2(1570, 650), "phase": 1.1},
				{"kind": "sign", "pos": Vector2(1490, 275), "label": "CÁI RĂNG"}
			],
			"merchants": [
				{"pos": Vector2(500, 400), "rot": -0.32, "name": "Cô Sáu", "product": "Trái cây", "price": 50, "stock": 10},
				{"pos": Vector2(1300, 450), "rot": 0.20, "name": "Chú Bảy Dừa", "product": "Nước dừa", "price": 70, "stock": 7},
				{"pos": Vector2(750, 750), "rot": 0.18, "name": "Dì Tư Bánh", "product": "Bánh dân gian", "price": 90, "stock": 5},
				{"pos": Vector2(1000, 350), "rot": -0.18, "name": "Anh Hai Miệt Vườn", "product": "Trái cây", "price": 55, "stock": 8}
			],
			"deliveries": [
				{"pos": Vector2(1400, 750), "name": "Tiệm Ánh Đèn"},
				{"pos": Vector2(350, 250), "name": "Bến Du Lịch"},
				{"pos": Vector2(1260, 650), "name": "Sân Khấu Nổi", "marker_offset": Vector2(250, -278), "npc_offset": Vector2(302, -294), "label_offset": Vector2(220, -378)}
			],
			"spots": [
				{"pos": Vector2(955, 220), "id": "cai_rang_bridge", "name": "Cầu Đèn Lồng"},
				{"pos": Vector2(260, 525), "id": "cai_rang_neon", "name": "Dãy Nhà Ven Sông"}
			],
			"portals": [
				{"pos": Vector2(960, 965), "target": "ninh_kieu", "spawn": Vector2(960, 185), "label": "Bến Ninh Kiều"},
				{"pos": Vector2(1550, 690), "target": "orchard", "spawn": Vector2(240, 535), "label": "Kênh Vườn Trái Cây"}
			],
			"currents": [
				{"pos": Vector2(940, 520), "force": Vector2(44, -12)},
				{"pos": Vector2(800, 810), "rot": 0.3, "force": Vector2(-34, -4)}
			],
			"water_style": {
				"flow": Vector2(1.0, -0.18),
				"speed": 1.0,
				"chop": 1.05,
				"density": 1.05,
				"water_tint": Color(0.42, 0.66, 0.70, 0.18),
				"foam_tint": Color(0.78, 0.88, 0.84, 0.22),
				"shadow_tint": Color(0.04, 0.18, 0.17, 0.18)
			},
			"upgrade_dock": {"pos": Vector2(1535, 655)}
		},
		"ninh_kieu": {
			"name": "Bến Ninh Kiều",
			"background": "res://assets/map_ninh_kieu.png",
			"quest_boards": [
				{"pos": Vector2(450, 600), "id": "ninh_kieu_pr", "name": "Quầy PR Du Lịch Đêm", "role": "Nhiệm vụ check-in", "npc_offset": Vector2(-20, 20)},
				{"pos": Vector2(1250, 800), "id": "ninh_kieu_tour", "name": "Bàn Điều Tour Ven Sông", "role": "Đơn đặc sản", "npc_offset": Vector2(-20, 20)}
			],
			"decorations": [
				{"kind": "lantern", "pos": Vector2(430, 430), "phase": 0.1},
				{"kind": "sign", "pos": Vector2(600, 290), "label": "NINH KIỀU"},
				{"kind": "sign", "pos": Vector2(1320, 710), "label": "TOUR ĐÊM"}
			],
			"merchants": [
				{"pos": Vector2(450, 750), "rot": 0.2, "name": "Quán Dừa Ven Bến", "product": "Nước dừa", "price": 65, "stock": 10},
				{"pos": Vector2(1460, 400), "rot": -0.2, "name": "Ghe Bánh Du Lịch", "product": "Bánh dân gian", "price": 85, "stock": 7},
				{"pos": Vector2(1100, 650), "rot": 0.12, "name": "Sạp Quà Miệt Vườn", "product": "Trái cây", "price": 60, "stock": 8}
			],
			"deliveries": [
				{"pos": Vector2(980, 250), "name": "Bến Du Lịch"},
				{"pos": Vector2(300, 400), "name": "Quầy Thông Tin"},
				{"pos": Vector2(1450, 550), "name": "Nhà Hàng Ven Sông"}
			],
			"spots": [
				{"pos": Vector2(510, 245), "id": "ninh_kieu_prom", "name": "Lối Dạo Ánh Neon"},
				{"pos": Vector2(1325, 210), "id": "ninh_kieu_wharf", "name": "Bến Tàu Đêm"}
			],
			"portals": [
				{"pos": Vector2(960, 110), "target": "cai_rang", "spawn": Vector2(960, 890), "label": "Chợ Nổi Cái Răng"},
				{"pos": Vector2(1740, 535), "target": "lantern", "spawn": Vector2(240, 540), "label": "Làng Đèn Lồng"}
			],
			"currents": [
				{"pos": Vector2(780, 520), "force": Vector2(34, 14)}
			],
			"upgrade_dock": {"pos": Vector2(270, 785)}
		},
		"orchard": {
			"name": "Kênh Vườn Trái Cây",
			"background": "res://assets/map_orchard_canals.png",
			"quest_boards": [
				{"pos": Vector2(300, 500), "id": "orchard_coop", "name": "Hợp Tác Xã Nhà Vườn", "role": "Đơn thu hoạch", "npc_offset": Vector2(-20, 20)}
			],
			"decorations": [
				{"kind": "lantern", "pos": Vector2(355, 410), "phase": 0.2},
				{"kind": "lantern", "pos": Vector2(1470, 690), "phase": 1.3},
				{"kind": "sign", "pos": Vector2(340, 250), "label": "NHÀ VƯỜN"}
			],
			"merchants": [
				{"pos": Vector2(500, 350), "rot": -0.1, "name": "Vườn Chôm Chôm", "product": "Trái cây", "price": 45, "stock": 12},
				{"pos": Vector2(1250, 400), "rot": 0.24, "name": "Ghe Dừa Non", "product": "Nước dừa", "price": 60, "stock": 8},
				{"pos": Vector2(1300, 750), "rot": -0.18, "name": "Lò Bánh Lá Dứa", "product": "Bánh dân gian", "price": 80, "stock": 6}
			],
			"deliveries": [
				{"pos": Vector2(1300, 550), "name": "Nhà Vườn Chín Ngọt"},
				{"pos": Vector2(350, 800), "name": "Bến Gom Hàng"}
			],
			"spots": [
				{"pos": Vector2(930, 230), "id": "orchard_bridge", "name": "Cầu Gỗ Nhà Vườn"},
				{"pos": Vector2(520, 610), "id": "orchard_lantern", "name": "Bến Trái Cây Neon"}
			],
			"portals": [
				{"pos": Vector2(180, 535), "target": "cai_rang", "spawn": Vector2(1690, 545), "label": "Chợ Nổi Cái Răng"},
				{"pos": Vector2(960, 960), "target": "lantern", "spawn": Vector2(960, 170), "label": "Làng Đèn Lồng"}
			],
			"currents": [
				{"pos": Vector2(1020, 520), "rot": -0.2, "force": Vector2(-20, 38)},
				{"pos": Vector2(700, 760), "rot": 0.35, "force": Vector2(42, -10)}
			],
			"upgrade_dock": {"pos": Vector2(260, 250)}
		},
		"lantern": {
			"name": "Làng Đèn Lồng",
			"background": "res://assets/map_lantern_village.png",
			"quest_boards": [
				{"pos": Vector2(450, 300), "id": "lantern_workshop", "name": "Xưởng Sáng Tạo Đèn Lồng", "role": "Chiến dịch hình ảnh", "npc_offset": Vector2(-20, 20)},
				{"pos": Vector2(1350, 600), "id": "festival_stage_office", "name": "Ban Tổ Chức Đêm Hội", "role": "Hợp đồng cuối", "npc_offset": Vector2(-20, 20)}
			],
			"decorations": [
				{"kind": "lantern", "pos": Vector2(465, 470), "phase": 0.3},
				{"kind": "lantern", "pos": Vector2(1210, 300), "phase": 0.9},
				{"kind": "lantern", "pos": Vector2(1535, 705), "phase": 1.7},
				{"kind": "sign", "pos": Vector2(1120, 205), "label": "LÀNG ĐÈN"}
			],
			"merchants": [
				{"pos": Vector2(450, 450), "rot": 0.16, "name": "Ghe Trái Cây Hội Đèn", "product": "Trái cây", "price": 58, "stock": 10},
				{"pos": Vector2(1450, 350), "rot": -0.25, "name": "Cô Út Dừa Xiêm", "product": "Nước dừa", "price": 68, "stock": 8},
				{"pos": Vector2(600, 750), "rot": 0.14, "name": "Tiệm Bánh Làng Nghề", "product": "Bánh dân gian", "price": 88, "stock": 8}
			],
			"deliveries": [
				{"pos": Vector2(1350, 700), "name": "Sân Khấu Nổi"},
				{"pos": Vector2(330, 190), "name": "Xưởng Đèn Lồng"}
			],
			"spots": [
				{"pos": Vector2(960, 210), "id": "lantern_arch", "name": "Cổng Đèn Lồng"},
				{"pos": Vector2(360, 585), "id": "lantern_temple", "name": "Miếu Nhỏ Ven Sông"}
			],
			"portals": [
				{"pos": Vector2(180, 540), "target": "ninh_kieu", "spawn": Vector2(1660, 535), "label": "Bến Ninh Kiều"},
				{"pos": Vector2(960, 110), "target": "orchard", "spawn": Vector2(960, 890), "label": "Kênh Vườn Trái Cây"}
			],
			"currents": [
				{"pos": Vector2(1030, 600), "force": Vector2(28, -28)}
			],
			"upgrade_dock": {"pos": Vector2(1665, 220)}
		}
	}
