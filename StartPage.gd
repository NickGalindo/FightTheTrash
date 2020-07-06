extends Node2D


onready var scoreLabel = $Menu/Label

func _on_Button_pressed() -> void:
	print("sss")
	get_tree().change_scene("res://World.tscn")

func _process(delta: float) -> void:
	scoreLabel.text = "Score: " + str(GlobalScoreNode.score)


func _on_Instructions_pressed() -> void:
	get_tree().change_scene("res://Instructions.tscn")


func _on_Credits_pressed() -> void:
	get_tree().change_scene("res://Credits.tscn")
