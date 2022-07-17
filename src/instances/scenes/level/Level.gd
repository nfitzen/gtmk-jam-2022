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
export var n_steps = 16

onready var tile_map = $"TileMap"
onready var camera = $"Camera2D"

func in_bounds(vec, size):
    return vec.x >= 0 and vec.y >= 0 and vec.x < size and vec.y < size
    
func weighted_range_choice(weights):
    # how fucking skeletal can the builtin set be
    var total_weights = 0
    for weight in weights:
        total_weights += weight
    
    var selector = randi() % total_weights
    var cumsum = 0
    var index = 0
    for weight in weights:
        cumsum += weight
        if cumsum > selector:
            return index
        index += 1

var die_grid_pos = Vector2(0, 0)

var grid = []

class MutableDieState:
    var top = 6
    var bottom = 1
    var sides = [4,2,3,5]

    func move(direction):
        var old_top = top
        top = sides[direction]
        sides[direction] = bottom
        bottom = sides[direction^2]
        sides[direction^2] = old_top

var logical_die_pos = Vector2(0, 0)
var logical_die_state = MutableDieState.new()

# Called when the node enters the scene tree for the first time.
func _ready():
    initialize_grid(grid_size, n_steps)

func debug_print_grid():
    for row in grid:
        print(row)
    print()

func update_tile(pos):
    if grid[pos.y][pos.x] > 0:
        tile_map.set_cellv(pos, WHITE_TILE)
    else:
        tile_map.set_cellv(pos, BLACK_TILE)

func initialize_grid(grid_size, n_steps):

    var tmp = round(grid_size / 2.0)
    camera.position = Vector2(tmp, tmp)

    var gen_weights = []

    for y in range(grid_size):
        var row = []
        var weights_row = []
        for x in range(grid_size):
            row.append(0)
            weights_row.append(5)
            tile_map.set_cell(x, y, BLACK_TILE)
        grid.append(row)
        gen_weights.append(weights_row)
        
    var initializer_die = MutableDieState.new()
    var initializer_die_grid_pos = Vector2(0, 0)
    
    for _i in range(n_steps):
        var weights = []
        for direction in range(LEFT):
            var hypothetical_pos = initializer_die_grid_pos + DELTAS[direction]
            if not in_bounds(hypothetical_pos, grid_size):
                weights.append(0)
            elif grid[hypothetical_pos.y][hypothetical_pos.x] > 93:
                weights.append(0)
            else:
                var weight = gen_weights[hypothetical_pos.y][hypothetical_pos.x]
                weights.append(weight)
        
        for y in range(grid_size):
            for x in range(grid_size):
                gen_weights[y][x] += 2
        gen_weights[initializer_die_grid_pos.y][initializer_die_grid_pos.x] = 1        
                
        var direction = weighted_range_choice(weights)
        initializer_die.move(direction)
        initializer_die_grid_pos += DELTAS[direction]
        grid[initializer_die_grid_pos.y][initializer_die_grid_pos.x] += initializer_die.top
        update_tile(initializer_die_grid_pos)
        debug_print_grid()

func _on_die_move(direction):
    logical_die_pos += DELTAS[direction]
    logical_die_state.move(direction)
    grid[logical_die_pos.y][logical_die_pos.x] -= logical_die_state.top
    update_tile(logical_die_pos)
    debug_print_grid()
    
