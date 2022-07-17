extends Node2D

export var value : int;

func _process(_delta):
    $left.visible = value >= 10;
    $right.visible = value >= 10;
    $middle.visible = value < 10;
    if($left.visible):
        $left.frame = value / 10;
        $right.frame = value % 10;
    else:
        $middle.frame = value;
