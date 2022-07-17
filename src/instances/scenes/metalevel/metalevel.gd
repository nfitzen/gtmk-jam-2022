extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Level = load("res://instances/scenes/level/Level.tscn")
var current_level
onready var level_display = get_node("CanvasLayer/Control/Level")
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    current_level = Level.instance()
    add_child(current_level)
    level_display.text = "Level " + str(level)

func change_level():
    remove_child(current_level)
    current_level = Level.instance()
    add_child(current_level)
    level += 1
    level_display.text = "Level " + str(level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
