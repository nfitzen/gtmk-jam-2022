# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 nfitzen, daatguy, UnrelatedString

extends Node2D

enum {UP, RIGHT, DOWN, LEFT}

func _process(_delta):
    $east.visible = $"../..".legal_move(RIGHT);
    $north.visible = $"../..".legal_move(UP);
    $west.visible = $"../..".legal_move(LEFT);
    $south.visible = $"../..".legal_move(DOWN);
