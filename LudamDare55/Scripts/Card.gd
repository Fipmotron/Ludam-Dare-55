extends Sprite2D

var Card_Num = 1

var Is_MouseEntered := false
var Change_Card := false
var Can_Change := true
var Moved_Up := false

func _ready():
	#-- Signals --#
	SignalManager.connect("Card_Transform", Callable(self, "_Card_Changer"))
	SignalManager.connect("Reset_CardChosen", Callable(self, "_Reset_Card"))
	SignalManager.connect("Card_YesChange", Callable(self, "_Yes_Change"))
	SignalManager.connect("Card_NoChange", Callable(self, "_No_Change"))
	
	_Sprite_Handler()

func _input(event):
	if event is InputEventMouseButton and Is_MouseEntered and not Change_Card and Can_Change:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			$CardTap.play()
			Change_Card = true
			Moved_Up = true
			$GPUParticles2D.emitting = true
			global_position = lerp(global_position, Vector2(global_position.x, global_position.y - 50), 0.5)
			SignalManager.emit_signal("Card_Chosen")
			SignalManager.emit_signal("Card_NoChange")
			print(Change_Card)
	elif event is InputEventMouseButton and Is_MouseEntered and Change_Card:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			Change_Card = false
			$GPUParticles2D.emitting = false
			global_position = lerp(global_position, Vector2(global_position.x, global_position.y + 50), 0.5)
			SignalManager.emit_signal("Card_YesChange")
			SignalManager.emit_signal("Card_Chosen")
			print(Change_Card)

func _Card_Changer(Num):
	if Change_Card:
		if Moved_Up:
			global_position = lerp(global_position, Vector2(global_position.x, global_position.y + 50), 0.5)
		
		$SummonCard.play()
		$GPUParticles2D.emitting = false
		
		SignalManager.emit_signal("Update_ActionArray", Num, Card_Num)
		Card_Num = Num
		_Sprite_Handler()
		print(Card_Num, " ", name)

func _No_Change():
	Can_Change = false

func _Yes_Change():
	Can_Change = true

func _Reset_Card():
	Change_Card = false

func Mouse_entered():
	Is_MouseEntered = true

func Mouse_exited():
	Is_MouseEntered = false

func _Sprite_Handler():
	var rng = RandomNumberGenerator.new()
	
	if Card_Num < 11:
		var Choice = rng.randi_range(1, 4)
		self.hframes = 10
		
		if Choice == 1:
			self.set_texture(load("res://Sprites/ClubCards-Sheet.png"))
		elif Choice == 2:
			self.set_texture(load("res://Sprites/DiamondCards-Sheet.png"))
		elif Choice == 3:
			self.set_texture(load("res://Sprites/HeartCards-Sheet.png"))
		elif Choice == 4:
			self.set_texture(load("res://Sprites/SpadeCards-Sheet.png"))
		
		self.frame = Card_Num - 1
	elif Card_Num == 11:
		var Choice = rng.randi_range(0, 2)
		self.hframes = 3
		
		self.set_texture(load("res://Sprites/RoyalCards-Sheet.png"))
		
		self.frame = Choice
	
	if get_parent().get_parent().get_parent().name.contains("Oppenent"):
		self.hframes = 1
		self.frame = 0
		self.set_texture(load("res://Sprites/CardBackSide.png"))
