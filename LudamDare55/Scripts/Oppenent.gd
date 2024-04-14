extends Node2D

@export var Enemy_Num := 1

var rng = RandomNumberGenerator.new()

var Card_Array := []
var _Card_Example := preload("res://Tscn Files/Card.tscn")

var Is_Busted := false

var Suspicion := 1

var _WaitTimer

var _CheckTimer := 1.0
var Check_Cheater := false
var Has_Sent := false

var GameOver := false

func _ready():
	$Gambeler/AnimationPlayer.play("Idle")
	
	#-- Signals --#
	SignalManager.connect("Oppenent_RollCards", Callable(self, "_Start_Oppenent"))
	SignalManager.connect("Oppenent_ClearCards", Callable(self, "_Clear_Cards"))
	SignalManager.connect("Oppenent_ReportCards", Callable(self, "_Report_Cards"))
	SignalManager.connect("In_CheatingMode", Callable(self, "_Check_Cheater"))
	SignalManager.connect("Change_Sus", Callable(self, "_Update_Sus"))
	SignalManager.connect("Lose_Sus", Callable(self, "_Sub_Sus"))
	SignalManager.connect("End_Game", Callable(self, "_Freeze"))

func _physics_process(delta):
	if Check_Cheater:
		if _WaitTimer > 0.0:
			_WaitTimer -= delta
			
			if Suspicion >= 1:
				if _WaitTimer < (2.0 / Suspicion):
					$Gambeler/AnimationPlayer.play("Sus")
				else:
					$Gambeler/AnimationPlayer.play("Idle")
			else:
				if _WaitTimer < 2.0:
					$Gambeler/AnimationPlayer.play("Sus")
				else:
					$Gambeler/AnimationPlayer.play("Idle")
			
		elif _WaitTimer <= 0.0:
			_CheckTimer -= delta
			
			if not Has_Sent:
				SignalManager.emit_signal("Cheater_Check")
				Has_Sent = true
			
			if Suspicion > 1:
				if _CheckTimer <= (0.25 / Suspicion):
					$Gambeler/AnimationPlayer.play("Caught")
			else:
				if _CheckTimer <= 0.25:
					$Gambeler/AnimationPlayer.play("Caught")
			
			
		if _CheckTimer <= 0.0:
			SignalManager.emit_signal("Cheater_Check")
			SignalManager.emit_signal("Cheater_Catch")
			$Gambeler/AnimationPlayer.play("GameOver")
			
			Has_Sent = false
			
			_CheckTimer = _Generate_CheckTimer()
			_WaitTimer = _Generate_WaitTimer()

func _Freeze():
	GameOver = true
	print("GRAHHHHHH GAME OVER :(((((())))))")

func _Update_Sus(a):
	Suspicion += a

func _Sub_Sus(a):
	Suspicion -= a

func _Generate_WaitTimer():
	if not GameOver:
		var Num = rng.randf_range(5.0, 50.0)
		
		if Suspicion < 1:
			Num = Num
		else:
			Num = Num / Suspicion
		
		return Num
	else:
		return 0.0

func _Generate_CheckTimer():
	if not GameOver:
		if Suspicion < 1:
			return 2.0
		else:
			return 2.0 / Suspicion
	elif GameOver:
		return 0.0

func _Start_Oppenent():
	var Card_Num = rng.randi_range(2, 3)
	
	for i in Card_Num:
		var Num_Card = rng.randi_range(1, 11)
		
		Card_Array.append(Num_Card)
		
		var New_Card = _Card_Example.instantiate()
		$CardContainer.add_child(New_Card)
		
		New_Card.get_child(0).Card_Num = Num_Card
	
	_Check_Busted()
	
	print("Oppenent Cards: ", Card_Array)

func _Check_Busted():
	if _Card_Sum() > 21:
		Is_Busted = true
		$Gambeler/AnimationPlayer.play("Busted")
	elif _Card_Sum() < 21:
		Is_Busted = false
		$Gambeler/AnimationPlayer.play("Idle")

func _Check_Cheater():
	if Check_Cheater and not GameOver:
		Check_Cheater = false
		$Gambeler/AnimationPlayer.play("Idle")
		_Check_Busted()
	elif not Check_Cheater and not GameOver:
		Check_Cheater = true
		_WaitTimer = _Generate_WaitTimer()
		print("Generate wait")

func _Card_Sum():
	var Sum = 0
	
	for i in Card_Array:
		Sum += i
	
	return Sum

func _Clear_Cards():
	Card_Array.clear()
	
	for i in $CardContainer.get_children():
		i.queue_free()

func _Report_Cards():
	SignalManager.emit_signal("Oppenents_CardReport", Enemy_Num, _Card_Sum())
