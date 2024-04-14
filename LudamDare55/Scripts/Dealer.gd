extends Node2D

var rng = RandomNumberGenerator.new()

var Suspicion := 1

var _WaitTimer

var _CheckTimer := 5.0
var Check_Cheater := false
var Has_Sent := false

var Dealers_Card
var GameOver := false

@onready var Game_Scene := get_node("/root/GameScene")

func _ready():
	$Sprite2D/AnimationPlayer.play("Idle")
	
	SignalManager.connect("In_CheatingMode", Callable(self, "_Check_Cheater"))
	SignalManager.connect("Change_Sus", Callable(self, "_Update_Sus"))
	SignalManager.connect("Lose_Sus", Callable(self, "_Sub_Sus"))
	SignalManager.connect("Give_Card", Callable(self, "_Card_Reciver"))
	SignalManager.connect("End_Game", Callable(self, "_Freeze"))

func _physics_process(delta):
	if Game_Scene.Day_Counter >= 3:
		if Check_Cheater:
			if _WaitTimer > 0.0:
				_WaitTimer -= delta
				
				$Sprite2D/AnimationPlayer.play("Idle")
			elif _WaitTimer <= 0.0:
				_CheckTimer -= delta
				
				if not Has_Sent:
					SignalManager.emit_signal("Request_Card")
					Has_Sent = true
				
				if _CheckTimer <= 1.0:
					$Sprite2D/AnimationPlayer.play("ChangeCard")
				else:
					$Sprite2D/AnimationPlayer.play("ChargeUp")
				
			if _CheckTimer <= 0.0:
				if not GameOver:
					get_node(Dealers_Card).Change_Card = true
					get_node(Dealers_Card)._Card_Changer(_CardNum_Generator())
					get_node(Dealers_Card).Change_Card = false
					
					Has_Sent = false
					
					_CheckTimer = _Generate_CheckTimer()
					_WaitTimer = _Generate_WaitTimer()

func _CardNum_Generator():
	var Num = rng.randi_range(1, 11)
	
	return Num

func _Card_Reciver(Card):
	Dealers_Card = Card

func _Check_Cheater():
	if Check_Cheater:
		Check_Cheater = false
		$Sprite2D/AnimationPlayer.play("Idle")
	elif not Check_Cheater:
		Check_Cheater = true
		_WaitTimer = _Generate_WaitTimer()

func _Freeze():
	GameOver = true

func _Update_Sus(a):
	Suspicion += a

func _Sub_Sus(a):
	Suspicion -= a

func _Generate_WaitTimer():
	var Num = rng.randf_range(20.0, 60.0)
	if Suspicion > 1:
		Num = (Num / Suspicion) * 2
	else:
		Num = (Num) * 2
	
	return Num

func _Generate_CheckTimer():
	var Num = rng.randf_range(5.0, 10.0)
	
	if Suspicion > 1:
		Num = Num / Suspicion
	
	return Num
