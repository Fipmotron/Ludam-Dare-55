extends Node2D

var masterbus := AudioServer.get_bus_index("Master")

func _ready():
	$StraightCheeksMusic.play()

func _on_start_button_pressed():
	$ButtonPressSFX.play()
	get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")


func _on_htp_button_pressed():
	$ButtonPressSFX.play()
	$Main/MainPanel.visible = false
	$Main/HTPPanel.visible = true


func _on_next_button_pressed():
	$ButtonPressSFX.play()
	$Main/HTPPanel/MainSubPanel.visible = false
	$Main/HTPPanel/CheatSubPanel.visible = true


func _on_next_2_button_pressed():
	$ButtonPressSFX.play()
	$Main/HTPPanel/CheatSubPanel.visible = false
	$Main/HTPPanel/DealerSubPanel.visible = true


func _on_back_button_pressed():
	$ButtonPressSFX.play()
	$Main/MainPanel.visible = true
	$Main/HTPPanel.visible = false


func _on_back2_button_pressed():
	$ButtonPressSFX.play()
	$Main/HTPPanel/MainSubPanel.visible = true
	$Main/HTPPanel/CheatSubPanel.visible = false


func _on_back3_button_pressed():
	$ButtonPressSFX.play()
	$Main/HTPPanel/CheatSubPanel.visible = true
	$Main/HTPPanel/DealerSubPanel.visible = false


func _on_quit_button_pressed():
	$ButtonPressSFX.play()
	get_tree().quit()

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(masterbus, value)
