extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Level = load("res://instances/scenes/level/Level.tscn")
var current_level
var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    current_level = Level.instance()
    add_child(current_level)

func change_level():
    remove_child(current_level)
    current_level = Level.instance()
    level += 1
    add_child(current_level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
