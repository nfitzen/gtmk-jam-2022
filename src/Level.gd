extends Node2D

enum {UP, RIGHT, DOWN, LEFT}

var deltas = [
    Vector2(0, 1),
    Vector2(1, 0),
    Vector2(0, -1),
    Vector2(-1, 0)
   ]

func in_bounds(vec, size):
    return vec.x >= 0 and vec.y >= 0 and vec.x < size and vec.y < size

var die_grid_pos = Vector2(0, 0)

var grid = []

class MutableDieState:
    var top = 1
    var bottom = 6
    var sides = [5,4,2,3]
    
    func move(direction):
        var old_top = top
        top = sides[direction]
        sides[direction] = bottom
        bottom = sides[direction^2]
        sides[direction^2] = old_top

# Called when the node enters the scene tree for the first time.
func _ready():
    initialize_grid(4, 8)
    
func debug_print_grid():
    for row in grid:
        print(row)
    print()

func initialize_grid(grid_size, n_steps):
    for _y in range(grid_size):
        var row = []
        for _x in range(grid_size):
            row.append(0)
        grid.append(row)
    var initializer_die = MutableDieState.new()
    var initializer_die_grid_pos = Vector2(0, 0)
    for _i in range(n_steps):
        var direction = randi() % 4
        while not in_bounds(initializer_die_grid_pos + deltas[direction], grid_size):
            direction = randi() % 4
        initializer_die.move(direction)
        initializer_die_grid_pos += deltas[direction]
        grid[initializer_die_grid_pos.y][initializer_die_grid_pos.x] += initializer_die.top
        debug_print_grid()
        


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
