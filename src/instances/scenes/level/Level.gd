# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 UnrelatedString, nfitzen

extends Node2D

enum {UP, RIGHT, DOWN, LEFT}

const DELTAS = [
    Vector2(0, 1),
    Vector2(1, 0),
    Vector2(0, -1),
    Vector2(-1, 0)
   ]

enum {
    BLACK_TILE = 0
    WHITE_TILE = 1
    }

export var grid_size = 4
export var n_steps = 8

onready var tile_map = $"TileMap"
onready var camera = $"Camera2D"

func in_bounds(vec, size):
    return vec.x >= 0 and vec.y >= 0 and vec.x < size and vec.y < size

func probably_not(x, y):
    return x != y or randi() % 3 == 0

func in_bounds_and_probably_not(vec, size, other): # this is unbelievably stupid but i'd rather not repeat the next-position expression lmao
    return in_bounds(vec, size) and probably_not(vec, other)

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
    initialize_grid(grid_size, n_steps)

func debug_print_grid():
    for row in grid:
        print(row)
    print()

func initialize_grid(grid_size, n_steps):
    for y in range(grid_size):
        var row = []
        for x in range(grid_size):
            row.append(0)
            tile_map.set_cell(x, y, BLACK_TILE)
        grid.append(row)
    var initializer_die = MutableDieState.new()
    var initializer_die_grid_pos = Vector2(0, 0)
    var previous_pos = Vector2(0, 0)
    for _i in range(n_steps):
        var direction = randi() % 4
        while not in_bounds_and_probably_not(initializer_die_grid_pos + DELTAS[direction], grid_size, previous_pos):
            direction = randi() % 4
        initializer_die.move(direction)
        initializer_die_grid_pos += DELTAS[direction]
        grid[initializer_die_grid_pos.y][initializer_die_grid_pos.x] += initializer_die.top
        tile_map.set_cellv(initializer_die_grid_pos, WHITE_TILE)
        debug_print_grid()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
