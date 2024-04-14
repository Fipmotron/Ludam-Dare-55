extends Node2D

var rng = RandomNumberGenerator.new()

var Suspicion := 1

var _WaitTimer

var _CheckTimer := 1.0
var Check_Cheater := false
var Has_Sent := false

var GameOver := false

@onready var Game_Scene := get_node("/root/GameScene")

func _ready():
	$Sprite2D/AnimationPlayer.play("Idle")
	
	SignalManager.connect("In_CheatingMode", Callable(self, "_Check_Cheater"))
	SignalManager.connect("Change_Sus", Callable(self, "_Update_Sus"))
	SignalManager.connect("Lose_Sus", Callable(self, "_Sub_Sus"))
	SignalManager.connect("End_Game", Callable(self, "_Freeze"))


func _physics_process(delta):
	if Game_Scene.Day_Counter >= 2:
		if Check_Cheater:
			if _WaitTimer > 0.0:
				_WaitTimer -= delta
				
				if Suspicion > 1:
					if _WaitTimer < (1.5 / Suspicion):
						$Sprite2D/AnimationPlayer.play("Sus")
					else:
						$Sprite2D/AnimationPlayer.play("Idle")
				else:
					if _WaitTimer < 1.5:
						$Sprite2D/AnimationPlayer.play("Sus")
					else:
						$Sprite2D/AnimationPlayer.play("Idle")
				
			elif _WaitTimer <= 0.0:
				_CheckTimer -= delta
				
				if not Has_Sent:
					SignalManager.emit_signal("Cheater_Check")
					Has_Sent = true
				
				if Suspicion > 1:
					if _CheckTimer <= (1.0 / Suspicion):
						$Sprite2D/AnimationPlayer.play("Caught")
				else:
					if _CheckTimer <= 1.0:
						$Sprite2D/AnimationPlayer.play("Caught")
				
				
			if _CheckTimer <= 0.0:
				SignalManager.emit_signal("Cheater_Check")
				SignalManager.emit_signal("Cheater_Catch")
				$Sprite2D/AnimationPlayer.play("GameOver")
				
				Has_Sent = false
				
				_CheckTimer = _Generate_CheckTimer()
				_WaitTimer = _Generate_WaitTimer()

func _Freeze():
	GameOver = true

func _Check_Cheater():
	if Check_Cheater and not GameOver:
		Check_Cheater = false
		$Sprite2D/AnimationPlayer.play("Idle")
	elif not Check_Cheater and not GameOver:
		Check_Cheater = true
		_WaitTimer = _Generate_WaitTimer()

func _Update_Sus(a):
	Suspicion += a

func _Sub_Sus(a):
	Suspicion -= a

func _Generate_WaitTimer():
	if not GameOver:
		var Num = rng.randf_range(5.0, 15.0)
		
		if Suspicion > 1:
			Num = Num / Suspicion
		
		return Num
	else:
		return 0.0

func _Generate_CheckTimer():
	if not GameOver:
		if Suspicion > 1:
			return 1.0 / Suspicion
		else:
			return 1.0
	else:
		return 0.0
