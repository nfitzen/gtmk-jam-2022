extends Node2D

enum {UP, RIGHT, DOWN, LEFT}

func _process(_delta):
    $east.visible = $"../..".legal_move(RIGHT);
    $north.visible = $"../..".legal_move(UP);
    $west.visible = $"../..".legal_move(LEFT);
    $south.visible = $"../..".legal_move(DOWN);
