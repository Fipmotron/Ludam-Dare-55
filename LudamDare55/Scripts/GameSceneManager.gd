extends Node2D

var Round_Counter := 1
var Day_Counter := 1

var Reporterd_Cards := 0

var Jackpot

var EnemyOne_Sum
var EnemyTwo_Sum

var EnemyOne_Win := false
var EnemyTwo_Win := false
var Player_Win := false

@onready var Betting_Mode := get_node("BettingMode")
@onready var Action_Mode := get_node("ActionMode")
@onready var DayEndMode := get_node("DayEndMode")
@onready var GameEndMode := get_node("GameEndMode")


var PlaySFX := true
var Dealers_Card

func _ready():
	$StraightCheeksMusic.play()
	
	#-- Signals --#
	SignalManager.connect("End_Round", Callable(self, "_End_Round"))
	SignalManager.connect("Oppenents_CardReport", Callable(self, "_Card_Report"))
	SignalManager.connect("Player_Sum", Callable(self, "_Winner_Handler"))
	SignalManager.connect("New_Jackpot", Callable(self, "_Jackpot_Updater"))
	SignalManager.connect("End_Game", Callable(self, "_End_Game"))
	SignalManager.connect("Give_Card", Callable(self, "_Card_Reciver"))

func _Jackpot_Updater(num):
	Jackpot = num

func _Card_Report(ENum, CSum):
	Reporterd_Cards += 1
	
	if ENum == 1:
		EnemyOne_Sum = CSum
	elif ENum == 2:
		EnemyTwo_Sum = CSum

func _Winner_Handler(Player_Sum):
	print("Player Sum: ", Player_Sum)
	
	if EnemyOne_Sum > 21:
		EnemyOne_Win = false
		print("Enemy One Busted")
	elif EnemyOne_Sum < 21:
		print("Enemy One Sum: ", EnemyOne_Sum)
	else:
		EnemyOne_Win = true
		print("Enemy One Win")
	
	if EnemyTwo_Sum > 21:
		EnemyTwo_Win = false
		print("Enemy Two Busted")
	elif EnemyTwo_Sum < 21:
		print("Enemy Two Sum: ", EnemyTwo_Sum)
	else:
		EnemyTwo_Win = true
		print("Enemy Two Win")
	
	if Player_Sum == 21:
		Player_Win = true
		print("Player Win (21)")
	
	var _Array = [Player_Sum, EnemyOne_Sum, EnemyTwo_Sum]
	_Array.sort()
	print(_Array)
	
	if not Player_Win and not EnemyOne_Win and not EnemyTwo_Win:
		
		if _Array[2] > 21:
			if _Array[1] == Player_Sum:
				Player_Win = true
			elif _Array[1] == EnemyTwo_Sum:
				EnemyTwo_Win = true
			elif _Array[1] == EnemyOne_Sum:
				EnemyOne_Win = true 
		elif _Array[2] > 21 and _Array[1] > 21:
			if _Array[0] == Player_Sum:
				Player_Win = true
			elif _Array[0] == EnemyTwo_Sum:
				EnemyTwo_Win = true
			elif _Array[0] == EnemyOne_Sum:
				EnemyOne_Win = true 
		else:
			if _Array[2] == Player_Sum:
				Player_Win = true
			elif _Array[2] == EnemyTwo_Sum:
				EnemyTwo_Win = true
			elif _Array[2] == EnemyOne_Sum:
				EnemyOne_Win = true 
	
	if Player_Win and not EnemyOne_Win and not EnemyTwo_Win:
		#Give Whole Jackpot
		$JackpotWinSFX.play()
		SignalManager.emit_signal("Returned_Amount", Jackpot)
		print("Player Win")
	elif Player_Win and EnemyOne_Win and EnemyTwo_Win:
		#Divide Jackpot by 3 and give to player
		$JackpotWinSFX.play()
		SignalManager.emit_signal("Returned_Amount", Jackpot/3)
		print("3-Way Tie")
	elif Player_Win and EnemyOne_Win or Player_Win and EnemyTwo_Win:
		#Divide Jackpot by 2 and give to player
		$JackpotWinSFX.play()
		SignalManager.emit_signal("Returned_Amount", Jackpot/2)
		print("Tie")
	elif not Player_Win and EnemyOne_Win or not Player_Win and EnemyTwo_Win:
		#No Player Jackpot
		$JackpotLoseSFX.play()
		SignalManager.emit_signal("Returned_Amount", 0)
		print("Loss")
	
	_End_Round(1)

func _End_Betting():
	Betting_Mode.visible = false
	Action_Mode.visible = true

func _End_Round(a):
	Round_Counter += a
	
	SignalManager.emit_signal("Oppenent_ClearCards")
	
	EnemyOne_Win = false
	EnemyTwo_Win = false
	Player_Win = false
	
	Betting_Mode.visible = true
	Action_Mode.visible = false
	
	Betting_Mode._Debt_Checker()
	
	if Round_Counter > 3:
		_End_Day()

func _End_Day():
	Betting_Mode.visible = false
	Action_Mode.visible = false
	DayEndMode.visible = true
	GameEndMode.visible = false
	Betting_Mode._Debt_Checker()

func _End_Game():
	if PlaySFX:
		$GameOverSFX.play()
		PlaySFX = false
	
	Betting_Mode.visible = false
	Action_Mode.visible = false
	DayEndMode.visible = false
	GameEndMode.visible = true

func _Card_Reciver(Card):
	Dealers_Card = Card

func Countinue_Button_down():
	$"ButtonPressSFX".play()
	
	Round_Counter = 1
	Day_Counter += 1
	
	SignalManager.emit_signal("New_MinBetting")
	SignalManager.emit_signal("Change_Sus", 1)
	
	Betting_Mode.visible = true
	Action_Mode.visible = false
	DayEndMode.visible = false
	GameEndMode.visible = false
	
	Betting_Mode._Debt_Checker()


func MainMenu_pressed():
	$"ButtonPressSFX".play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
