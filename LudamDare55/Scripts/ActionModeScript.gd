extends Control

var Betted_Amount
var Jackpot_Num

var rng = RandomNumberGenerator.new()
var Card_Array := []


var Is_Busted := false

@onready var ChoiceMode := get_node("ChoiceMode")
@onready var CheatingMode := get_node("CheatingMode")

@onready var Cheat_Button := get_node("ChoiceMode/CheatButton")
@onready var Hit_Button := get_node("ChoiceMode/HitButton")
@onready var Stand_Button := get_node("ChoiceMode/StandButton")
@onready var Surrender_Button := get_node("ChoiceMode/SurrenderButton")

@onready var Change_Button := get_node("CheatingMode/ChangeButton")

var _Card_Example := preload("res://Tscn Files/Card.tscn")

var Card_Transform_Num := 1
var Card_Selected := false
var Transform_Selected := false

var Is_Cheating := false
var Is_Looking := false
var Is_Checked := false
var Is_Caught := false

var PlayCardChange := true

var Charge_Change := false
var Charge_Time := 0.0

var IsUp := true

func _ready():
	#-- Signals --#
	SignalManager.connect("Place_Bet", Callable(self, "_Bet_Container"))
	SignalManager.connect("Card_Chosen", Callable(self, "_Card_Selected"))
	SignalManager.connect("Update_ActionArray", Callable(self, "_Array_Updater"))
	SignalManager.connect("Cheater_Check", Callable(self, "_Update_CCheck"))
	SignalManager.connect("Cheater_Catch", Callable(self, "_Update_CCaught"))
	SignalManager.connect("Request_Card", Callable(self, "_Card_Requested"))
	SignalManager.connect("End_Game", Callable(self, "_Freeze"))

func _Freeze():
	Charge_Change = false

func _physics_process(delta):
	if Charge_Change:
		Charge_Time += delta
		
		if PlayCardChange:
			$CardChangeSFX.play()
			PlayCardChange = false
		
		if Charge_Time >= 10.0:
			Charge_Time = 0.0
			
			SignalManager.emit_signal("Card_Transform", Card_Transform_Num)
			
			Charge_Change = false
			Card_Selected = false
			Charge_Change = false
			PlayCardChange = true
			$CardChangeSFX.stop()
			Is_Cheating = false
			Change_Button.disabled = true
			
			SignalManager.emit_signal("Card_YesChange")
			SignalManager.emit_signal("Reset_CardChosen")
	elif not Charge_Change:
		Charge_Time -= delta
		$CardChangeSFX.stop()
		PlayCardChange = true
		if Charge_Time <= 0.0:
			Charge_Time = 0.0
	
	$CheatingMode/ChargeSlider.value = Charge_Time

func _Array_Updater(Num, CNum):
	Card_Array.erase(CNum)
	Card_Array.append(Num)
	_Check_Busted()
	print(Card_Array)

func _Bet_Container(Amount):
	Betted_Amount = Amount
	
	_ReRoll_Cards()

func Cheat_Button_Down():
	$"../ButtonPressSFX".play()
	
	ChoiceMode.visible = false
	CheatingMode.visible = true
	
	SignalManager.emit_signal("In_CheatingMode")

func Cheat_BackButton_Down():
	$"../ButtonPressSFX".play()
	
	ChoiceMode.visible = true
	CheatingMode.visible = false
	Change_Button.disabled = true
	Card_Selected = false
	Transform_Selected = false
	
	SignalManager.emit_signal("In_CheatingMode")

func Cheat_ChangeButton_Down():
	$"../ButtonPressSFX".play()
	
	Charge_Change = true
	Is_Cheating = true

func Cheat_ChangeButton_Up():
	Charge_Change = false
	Is_Cheating = false

func _Card_Requested():
	var Card = $CardContainer.get_children().pick_random().get_child(0)
	
	SignalManager.emit_signal("Give_Card", Card.get_path())

func _Update_CCheck():
	if not Is_Looking:
		Is_Looking = true
	elif Is_Looking:
		Is_Looking = false
	
	if Is_Looking and Is_Cheating:
		Is_Checked = true
	
	_Cheater_Check()

func _Update_CCaught():
	if Is_Cheating:
		Is_Caught = true
	
	_Cheater_Check()

func _Cheater_Check():
	if Is_Cheating:
		if Is_Checked:
			print("Increased Suspicion")
			SignalManager.emit_signal("Change_Sus", 1)
			Is_Checked = false
		
		if Is_Caught:
			print("End Game")
			SignalManager.emit_signal("End_Game")

func _Card_Selected():
	if not Card_Selected:
		Card_Selected = true
	elif Card_Selected:
		Card_Selected = false
	
	Activate_Change()

func Hit_Button_Down():
	$"../ButtonPressSFX".play()
	
	var new_rng = rng.randi_range(1, 11)
	
	Card_Array.append(new_rng)
	_Check_Busted()
	
	var New_Card = _Card_Example.instantiate()
	$CardContainer.add_child(New_Card)
	
	New_Card.get_child(0).Card_Num = new_rng
	New_Card.get_child(0)._Sprite_Handler()
	
	SignalManager.emit_signal("Lose_Sus", 1)
	
	print(Card_Array, " ", _Card_Sum())

func _ReRoll_Cards():
	var rng_num_1 = rng.randi_range(1, 11)
	var rng_num_2 = rng.randi_range(1, 11)
	
	Jackpot_Num = rng.randi_range(25000, 100000) + Betted_Amount
	SignalManager.emit_signal("New_Jackpot", Jackpot_Num)
	
	Card_Array.append(rng_num_1)
	Card_Array.append(rng_num_2)
	
	$CardContainer/Card1/TempCard1.Card_Num = rng_num_1
	$CardContainer/Card2/TempCard1.Card_Num = rng_num_2
	
	$CardContainer/Card1/TempCard1._Sprite_Handler()
	$CardContainer/Card2/TempCard1._Sprite_Handler()
	
	_Check_Busted()
	
	print(Card_Array, " ", _Card_Sum(), " JackPot:", Jackpot_Num)

func _Clear_Cards():
	Card_Array.clear()
	
	for i in $CardContainer.get_children().size():
		
		if $CardContainer.get_children().size() > 2 and not $CardContainer.get_child(i).name.contains("Card"):
			$CardContainer.get_child(i).queue_free()

func _Check_Busted():
	if _Card_Sum() > 21:
		Is_Busted = true
		
		Hit_Button.disabled = true
		Stand_Button.disabled = true
	elif _Card_Sum() <= 21:
		Is_Busted = false
		
		Hit_Button.disabled = false
		Stand_Button.disabled = false

func _Card_Sum():
	var Sum = 0
	
	for i in Card_Array:
		Sum += i
	
	return Sum

func Stand_Button_Down():
	$"../ButtonPressSFX".play()
	
	# End Round
	SignalManager.emit_signal("Oppenent_ReportCards")
	SignalManager.emit_signal("Player_Sum", _Card_Sum())
	_Clear_Cards()

func Surrender_Button_Down():
	$"../ButtonPressSFX".play()
	
	if Is_Busted:
		SignalManager.emit_signal("Returned_Amount", 0)
		SignalManager.emit_signal("End_Round", 1)
	elif not Is_Busted:
		SignalManager.emit_signal("Returned_Amount", (Betted_Amount/2))
		SignalManager.emit_signal("End_Round", 1)
	
	SignalManager.emit_signal("Lose_Sus", 2)
	
	_Clear_Cards()


func AceCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 1
	Transform_Selected = true
	Activate_Change()

func TwoCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 2
	Transform_Selected = true
	Activate_Change()

func ThreeCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 3
	Transform_Selected = true
	Activate_Change()

func FourCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 4
	Transform_Selected = true
	Activate_Change()

func FiveCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 5
	Transform_Selected = true
	Activate_Change()

func SixCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 6
	Transform_Selected = true
	Activate_Change()

func SevenCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 7
	Transform_Selected = true
	Activate_Change()

func EightCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 8
	Transform_Selected = true
	Activate_Change()

func NineCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 9
	Transform_Selected = true
	Activate_Change()

func TenCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 10
	Transform_Selected = true
	Activate_Change()

func ElevenCard_down():
	$"../ButtonPressSFX".play()
	
	Card_Transform_Num = 11
	Transform_Selected = true
	Activate_Change()

func Activate_Change():
	if Card_Selected and Transform_Selected:
		Change_Button.disabled = false


func _on_drop_down_button_button_down():
	if IsUp:
		$CheatingMode/DropDownButton.global_position.y += 150
		$CheatingMode/ScrollContainer.global_position.y += 150
		IsUp = false
	elif not IsUp:
		$CheatingMode/DropDownButton.global_position.y -= 150
		$CheatingMode/ScrollContainer.global_position.y -= 150
		IsUp = true
