# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 nfitzen

extends Node

func _ready():
    randomize()
    get_tree().change_scene("res://instances/scenes/level/Level.tscn")
