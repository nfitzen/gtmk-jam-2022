# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 nfitzen, daatguy, UnrelatedString

extends AnimatedSprite

onready var Die = preload("res://instances/objects/Die.tscn");
onready var Sound = preload("res://instances/objects/Sound.tscn");
onready var drop = preload("res://assets/sounds/drop.wav");
var hit = false;

var fast = false;

func _ready():
    if fast:
        self.frame = 8;
    else:
        self.frame = 0;
        
func _process(_delta):
    if(frame >= 12 && hit == false):
        $"../Camera".shake = 4;
        hit = true;

func _on_DieIn_animation_finished():
    var die = Die.instance();
    $"..".add_child(die); 
    var sound = Sound.instance();
    sound.stream = drop;
    $"..".add_child(sound);
    queue_free();
   
