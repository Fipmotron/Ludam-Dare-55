extends Control


@export var Max_Betting_Amount := 25000.0
var Minumum_Betting_Amount := 1000.0
var Betted_Amount := 1000.0

@onready var Bet_Text := get_node("BetText")
@onready var Limit_Text := get_node("LimitText")

@onready var GameScene := get_node("/root/GameScene")

func _ready():
	Bet_Text.text = "$" + '%07d' % Betted_Amount
	
	_Set_LimitText()
	
	#-- Signals --#
	SignalManager.connect("Returned_Amount", Callable(self, "_Return_Amount"))
	SignalManager.connect("New_MinBetting", Callable(self, "_New_Amount"))

func _physics_process(_delta):
	if Betted_Amount < Minumum_Betting_Amount:
		Betted_Amount = Minumum_Betting_Amount
	
	Bet_Text.text = "$" + '%07d' % Betted_Amount

func _New_Amount():
	var Num = (Minumum_Betting_Amount * (1.5 * GameScene.Day_Counter))
	Minumum_Betting_Amount = Num
	print("Min Bet: ", Minumum_Betting_Amount)

func _Debt_Checker():
	print("Max Bet: ", Max_Betting_Amount)
	
	if Max_Betting_Amount < Minumum_Betting_Amount:
		SignalManager.emit_signal("End_Game")

func _Return_Amount(a):
	Max_Betting_Amount += a
	
	_Set_LimitText()

func _Set_LimitText():
	Limit_Text.text = "Limit: $" + '%07d' % Max_Betting_Amount
	
	if Betted_Amount > Max_Betting_Amount:
		Betted_Amount = Max_Betting_Amount
	
	if Betted_Amount < Minumum_Betting_Amount:
		Betted_Amount = Minumum_Betting_Amount
	
	Bet_Text.text = "$" + '%07d' % Betted_Amount

func _Add_Button_down():
	$"../ButtonPressSFX".play()
	Betted_Amount += 1000
	
	if Betted_Amount > Max_Betting_Amount:
		Betted_Amount = Max_Betting_Amount
	
	Bet_Text.text = "$" + '%07d' % Betted_Amount

func _Sub_Button_down():
	$"../ButtonPressSFX".play()
	Betted_Amount -= 1000
	
	if Betted_Amount < Minumum_Betting_Amount:
		Betted_Amount = Minumum_Betting_Amount
	
	Bet_Text.text = "$" + '%07d' % Betted_Amount

func _Place_Bet():
	$"../ButtonPressSFX".play()
	
	SignalManager.emit_signal("Place_Bet", Betted_Amount)
	SignalManager.emit_signal("Oppenent_RollCards")
	
	Max_Betting_Amount -= Betted_Amount
	
	GameScene._End_Betting()
