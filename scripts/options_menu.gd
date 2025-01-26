extends Control



func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_pressed():
	get_tree().quit()


func _on_audio_pressed():
	var masterBusIndex = AudioServer.get_bus_index("Master")
	Audio
