extends Node

func _ready():
	randomize()
	get_tree().change_scene("res://instances/scenes/level/Level.tscn")
