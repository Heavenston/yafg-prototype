extends Control

onready var title = $MarginContainer/VBoxContainer/Control/Label

func _on_PlayButton_pressed():
	var _err = get_tree().change_scene("res://scenes/test.tscn")

func _process(_delta):
	title.rect_rotation = sin(OS.get_ticks_usec() / 500000.0) * 5.0
