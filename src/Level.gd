extends Node2D

enum {UP, RIGHT, DOWN, LEFT}

var die_grid_pos = Vector2(0, 0)

var grid = [[]]

var die_transitions = { # with this face on top, what's on top after rolling in each direction
    1: [,2,,5],
    2: [4,6,3,1],
    3: [2,,5,],
    4: [5,,2,],
    5: [3,1,4,6],
    6: [,5,,2]
   }

# Called when the node enters the scene tree for the first time.
func _ready():
    initialize_grid(8)

func initialize_grid(n_steps):
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
