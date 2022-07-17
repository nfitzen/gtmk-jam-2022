extends AnimatedSprite

onready var Die = preload("res://instances/objects/Die.tscn");

var fast = false;

func _ready():
    if fast:
        self.frame = 8;
    else:
        self.frame = 0;

func _on_DieIn_animation_finished():
    var die = Die.instance();
    $"..".add_child(die);
    queue_free();
