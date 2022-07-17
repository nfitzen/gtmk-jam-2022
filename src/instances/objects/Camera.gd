extends Camera2D

var shake = 0.0;
var decay = 0.5;

func _process(_delta):
    offset.x = rand_range(-shake, shake);
    offset.y = rand_range(-shake, shake);
    shake *= decay;


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
