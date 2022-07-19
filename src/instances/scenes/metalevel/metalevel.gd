# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 nfitzen, daatguy, UnrelatedString

extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Level = load("res://instances/scenes/level/Level.tscn")
var current_level
onready var level_display = get_node("CanvasLayer/Control/Level")
var level = 1

export var progression = [
    [2, 1],
    [3, 4],
    [3, 4],
    [3, 5],
    [3, 7],
    [3, 12],
    [4, 6],
    [4, 8],
    [4, 8],
    [4, 10],
    [4, 10],
    [4, 13],
    [4, 16],
    [3, 18],
    [4, 22],
    [5, 6],
    [5, 10],
    [5, 15],
    [5, 20],
    [5, 27],
    [5, 27],
    [3, 40],
    [6, 30],
    [6, 36],
    [6, 45]
    ]

func set_progression(level, level_num: int) -> void:
    var setting
    if level_num > progression.size():
        setting = progression[-1]
    else:
        setting = progression[level_num-1]
    var grid_size = setting[0]
    var n_steps = setting[1]

    level.grid_size = grid_size
    level.n_steps = n_steps

# Called when the node enters the scene tree for the first time.
func _ready():
    current_level = Level.instance()
    set_progression(current_level, level)
    add_child(current_level)
    level_display.text = "Level " + str(level)

func change_level():
    remove_child(current_level)
    current_level.queue_free()
    level += 1
    current_level = Level.instance()
    set_progression(current_level, level)
    level_display.text = "Level " + str(level)
    add_child(current_level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
