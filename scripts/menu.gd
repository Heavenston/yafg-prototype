tool
extends Control

onready var title: Label = $VBoxContainer/title

func _process(_delta):
	title.rect_pivot_offset = title.rect_size / 2
	title.rect_rotation = sin(float(OS.get_ticks_msec()) / 1000) * 5

func _on_PlayButton_pressed():
	if get_tree().current_scene.name == "Test":
		var _val = get_tree().reload_current_scene()
	else:
		var _val = get_tree().change_scene("res://scenes/test.tscn")

func _on_FullScreenButton_pressed():
	OS.window_fullscreen = not OS.window_fullscreen

func _on_QuitButton_pressed():
	get_tree().quit()
