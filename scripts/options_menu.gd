extends Control

func setUp() -> void:
	self.z_index = 100

func _on_quit_pressed():
	get_tree().quit()

func _on_audio_pressed():
	var masterBusIndex = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(masterBusIndex, !AudioServer.is_bus_mute(masterBusIndex))
