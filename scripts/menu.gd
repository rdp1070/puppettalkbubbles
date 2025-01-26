extends Control



func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/level3.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_audio_pressed():
	var masterBusIndex = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(masterBusIndex, !AudioServer.is_bus_mute(masterBusIndex))
