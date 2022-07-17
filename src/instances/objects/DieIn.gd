extends AnimatedSprite

onready var Die = preload("res://instances/objects/Die.tscn");

func _on_DieIn_animation_finished():
    var die = Die.instance();
    $"..".add_child(die);
    queue_free();
