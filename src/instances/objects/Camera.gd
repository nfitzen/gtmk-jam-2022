extends Camera2D

var shake = 0.0;
var decay = 0.5;

func _process(_delta):
    offset.x = rand_range(-shake, shake);
    offset.y = rand_range(-shake, shake);
    shake *= decay;

func _ready():
    var hue = randf();
    var darksat = randf() * 0.7;
    $"CanvasLayer/ColorRect".material.set_shader_param("dark", Vector3(hue, randf(), randf() * 0.07));
    $"CanvasLayer/ColorRect".material.set_shader_param("med", Vector3(hue + 0.2 * randf(), randf() * 0.5, randf() * 0.2 + 0.3));
    $"CanvasLayer/ColorRect".material.set_shader_param("light", Vector3(hue + 0.3 * randf(), randf(), randf() * 0.3 + 0.7));
