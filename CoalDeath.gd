extends Node2D


onready var timer = $Timer

func _ready():
	timer.start(5)



func _on_Timer_timeout() -> void:
	get_tree().change_scene("res://StartPage.tscn")
