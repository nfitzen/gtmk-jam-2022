extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Level = load("res://instances/scenes/level/Level.tscn")
var level

# Called when the node enters the scene tree for the first time.
func _ready():
    level = Level.instance()
    add_child(level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
