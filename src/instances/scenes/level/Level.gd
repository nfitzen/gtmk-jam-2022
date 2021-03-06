# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 nfitzen, daatguy, UnrelatedString

extends Node2D

enum {UP, RIGHT, DOWN, LEFT}

const DELTAS = [
    Vector2(0, -1),
    Vector2(1, 0),
    Vector2(0, 1),
    Vector2(-1, 0)
   ]

enum {
    BLACK_TILE = 0
    WHITE_TILE = 1
    }

export var grid_size = 4
export var n_steps = 16

onready var Number = preload("res://instances/objects/Number.tscn");
onready var Die = preload("res://instances/objects/DieIn.tscn");

onready var tile_map = $TileMap
onready var camera = $Camera

func in_bounds(vec: Vector2, size: int):
    return vec.x >= 0 and vec.y >= 0 and vec.x < size and vec.y < size
    
func weighted_range_choice(weights: Array):
    # how fucking skeletal can the builtin set be
    var total_weights = 0
    for weight in weights:
        total_weights += weight
    
    var selector = randi() % total_weights
    # print(weights, selector)
    var cumsum = 0
    var index = 0
    for weight in weights:
        cumsum += weight
        if cumsum > selector:
            return index
        index += 1

var die_grid_pos = Vector2(0, 0)

var grid = []
var original_grid = []

class MutableDieState:
    var top = 6
    var bottom = 1
    var sides = [4,2,3,5]

    func move(direction):
        print("Moving " + str(direction));
        var old_top = top
        top = sides[direction]
        sides[direction] = bottom
        bottom = sides[direction^2]
        sides[direction^2] = old_top

var logical_die_pos
var logical_die_state

func reset_logical_die():
    logical_die_pos = Vector2(0, 0)
    logical_die_state = MutableDieState.new()

func reset_grid():
    for y in range(grid_size):
        for x in range(grid_size):
            grid[y][x] = original_grid[y][x]
            update_tile(Vector2(x, y))

# Called when the node enters the scene tree for the first time.
func _ready():
    initialize_grid(grid_size, n_steps)
    reset_logical_die()

func debug_print_grid():
    for row in grid:
        print(row)
    print()

func update_tile(pos: Vector2):
    get_node("Numbers/" + str(pos.y * grid_size + pos.x)).value = grid[pos.y][pos.x];
    if grid[pos.y][pos.x] > 0:
        tile_map.set_cellv(pos, WHITE_TILE)
    else:
        tile_map.set_cellv(pos, BLACK_TILE)

func initialize_grid(grid_size: int, n_steps: int):
    for y in range(grid_size):
        for x in range(grid_size):
            var new_num = Number.instance();
            new_num.position.x = x * 17;
            new_num.position.y = y * 13;
            new_num.name = "" + str(y * grid_size + x);
            $Numbers.add_child(new_num);

    var tmp = round(grid_size / 2.0)
    camera.position = Vector2(tmp*17, tmp*13)

    var gen_weights = []

    for y in range(grid_size):
        var row = []
        var clone_row = []
        var weights_row = []
        for x in range(grid_size):
            row.append(0)
            clone_row.append(0)
            weights_row.append(1)
            tile_map.set_cell(x, y, BLACK_TILE)
        original_grid.append(row)
        grid.append(clone_row)
        gen_weights.append(weights_row)
        
    var initializer_die = MutableDieState.new()
    var initializer_die_grid_pos = Vector2(0, 0)
    
    for _i in range(n_steps):
        var weights = []
        for direction in range(LEFT+1):
            var hypothetical_pos = initializer_die_grid_pos + DELTAS[direction]
            if not in_bounds(hypothetical_pos, grid_size):
                weights.append(0)
            elif original_grid[hypothetical_pos.y][hypothetical_pos.x] > 93:
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
        original_grid[initializer_die_grid_pos.y][initializer_die_grid_pos.x] += initializer_die.bottom
        grid[initializer_die_grid_pos.y][initializer_die_grid_pos.x] += initializer_die.bottom
        update_tile(initializer_die_grid_pos)
        debug_print_grid()
        
    for y in range(grid_size):
        for x in range(grid_size):
            get_node("Numbers/" + str(y * grid_size + x)).value = grid[y][x];

func check_win() -> bool:
    for row in grid:
        for val in row:
            if val > 0:
                return false
    return true

func check_loss(die_pos: Vector2) -> bool:
    for d in DELTAS:
        var tmp = die_pos+d
        if grid[tmp.y][tmp.x] > 0:
            return false
    return true

func _on_die_move(direction: int):
    logical_die_pos += DELTAS[direction]
    logical_die_state.move(direction)
    grid[logical_die_pos.y][logical_die_pos.x] = max(
        0,
        grid[logical_die_pos.y][logical_die_pos.x] - logical_die_state.bottom
        )
    update_tile(logical_die_pos)
    debug_print_grid()

    if check_win():
        $"Die".exit();
        #emit_signal("level_won")

func legal_move(direction: int):
    var pos = logical_die_pos + DELTAS[direction]
    return in_bounds(pos, grid_size) and grid[pos.y][pos.x]
    
func _on_restart_level():
    reset_logical_die()
    reset_grid()
    $"Die".queue_free();
    var die = Die.instance();
    die.fast = true;
    add_child(die);
