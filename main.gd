extends Node2D

var money = 500
var inventory = []
var current_merchant = null

@onready var ui = $UI

func _ready():
	var ev = InputEventKey.new()
	ev.keycode = KEY_E
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		InputMap.action_add_event("interact", ev)
	
	update_ui()

func _process(delta):
	if current_merchant and Input.is_action_just_pressed("interact"):
		current_merchant.interact()

func show_interaction(show: bool, merchant: Node):
	if show:
		current_merchant = merchant
		ui.get_node("MsgPanel").visible = true
	else:
		if current_merchant == merchant:
			current_merchant = null
			ui.get_node("MsgPanel").visible = false

func update_ui():
	ui.get_node("Panel/MoneyLabel").text = "Tiền: " + str(money) + "k"
	ui.get_node("Panel/InvLabel").text = "Kho: " + str(inventory.size()) + " món"
