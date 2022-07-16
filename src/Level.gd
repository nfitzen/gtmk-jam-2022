extends Node2D

enum {UP, RIGHT, DOWN, LEFT}

var die_grid_pos = Vector2(0, 0)

var grid = [[]]

class MutableDieState:
    var top = 1
    var bottom = 6
    var sides = [5,4,2,3]
    
    func move(direction):
        var old_top = top
        top = sides[direction]
        sides[direction] = bottom
        bottom = sides[(direction+2)%4]
        sides[(direction+2)%4] = old_top

# Called when the node enters the scene tree for the first time.
func _ready():
    initialize_grid(8)

func initialize_grid(n_steps):
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
