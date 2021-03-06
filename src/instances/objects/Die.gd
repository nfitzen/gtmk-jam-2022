# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: (C) 2022 nfitzen, daatguy, UnrelatedString

extends Node2D

signal die_move
signal restart_level

signal level_won

onready var Sound = preload("res://instances/objects/Sound.tscn");
onready var exit = preload("res://assets/sounds/lift.wav");
onready var outline_on = preload("res://assets/sounds/on.wav");
onready var outline_off = preload("res://assets/sounds/off.wav");
onready var flips = [
    preload("res://assets/sounds/flip0.wav"),
    preload("res://assets/sounds/flip1.wav"),
    preload("res://assets/sounds/flip2.wav"),
    preload("res://assets/sounds/flip3.wav"),
    preload("res://assets/sounds/flip4.wav"),
    ];
    
var outline_sound = -1;
var lockout : bool
var queued : int
var abort_frames = -1;
enum {
    TOP,
    BOTTOM,
    NORTH,
    SOUTH,
    EAST,
    WEST,
   }
enum {UP, RIGHT, DOWN, LEFT}
var sides
var side_indices = {
    "1" : 0,
    "2" : 1,
    "2p" : 2,
    "3" : 3,
    "3p" : 4,
    "4" : 5,
    "5" : 6,
    "6" : 7,
    "6p" : 8,
   };
var indicator_lock : bool = false;

func reset_state():
    queued = -1
    sides = ["6", "1", "3", "4", "5", "2"]
    lockout = false

func _ready():
    connect("level_won", $"../..", "change_level")
    reset_state()
    connect("die_move", $"..", "_on_die_move")
    connect("restart_level", $"..", "_on_restart_level")
    connect("restart_level", self, "_on_restart_level")
    lockout = true;
    abort_frames = 1;
    self.frame = 0;
    move_left();

func prime(inp : String):
    if(inp == "1" || inp == "4" || inp == "5"): return inp;
    if(inp.substr(1, 2) == "p"): return inp.substr(0, 1);
    return inp + "p";
    
func get_start_frame(side : String, transition : int):
    return 1 + side_indices[side] * 54 + (8 - transition) * 6;

func move_left():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "left";
    var old_sides = [] + sides;
    if(abort_frames == -1):
        sides[TOP] = old_sides[EAST];
        sides[BOTTOM] = old_sides[WEST];
        sides[NORTH] = prime(old_sides[NORTH]);
        sides[SOUTH] = prime(old_sides[SOUTH]);
        sides[EAST] = old_sides[BOTTOM];
        sides[WEST] = old_sides[TOP];
    $incoming.animation = "moving";
    $incoming.flip_h = true;
    $incoming.playing = true;
    $incoming.frame = get_start_frame(prime(old_sides[EAST]), 5);
    $old.animation = "moving";
    $old.visible = true;
    $old.playing = true;
    $old.frame = get_start_frame(old_sides[TOP], 0);
    $passenger.animation = "moving";
    $passenger.visible = true;
    $passenger.playing = true;
    $passenger.frame = get_start_frame(old_sides[SOUTH], 8);
    
func move_right():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "right";
    var old_sides = [] + sides;
    if(abort_frames == -1):
        sides[TOP] = old_sides[WEST];
        sides[BOTTOM] = old_sides[EAST];
        sides[NORTH] = prime(old_sides[NORTH]);
        sides[SOUTH] = prime(old_sides[SOUTH]);
        sides[EAST] = old_sides[TOP];
        sides[WEST] = old_sides[BOTTOM];
    $incoming.animation = "moving";
    $incoming.playing = true;
    $incoming.frame = get_start_frame(old_sides[WEST], 5);
    $old.animation = "moving";
    $old.flip_h = true;
    $old.visible = true;
    $old.playing = true;
    $old.frame = get_start_frame(prime(old_sides[TOP]), 0);
    $passenger.animation = "moving";
    $passenger.flip_h = true;
    $passenger.visible = true;
    $passenger.playing = true;
    $passenger.frame = get_start_frame(prime(old_sides[SOUTH]), 8);
    
func move_up():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "up";
    var old_sides = [] + sides;
    if(abort_frames == -1):
        sides[TOP] = old_sides[SOUTH];
        sides[BOTTOM] = old_sides[NORTH];
        sides[NORTH] = old_sides[TOP];
        sides[SOUTH] = old_sides[BOTTOM];
        sides[EAST] = prime(old_sides[EAST]);
        sides[WEST] = prime(old_sides[WEST]);
    $incoming.animation = "moving";
    $incoming.playing = true;
    $incoming.frame = get_start_frame(old_sides[SOUTH], 3);
    $old.animation = "moving";
    $old.visible = true;
    $old.playing = true;
    $old.frame = get_start_frame(old_sides[TOP], 1);
    $passenger.visible = false;
    $passenger.playing = false;
    
func move_down():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "down";
    var old_sides = [] + sides;
    if(abort_frames == -1):
        sides[TOP] = old_sides[NORTH];
        sides[BOTTOM] = old_sides[SOUTH];
        sides[NORTH] = old_sides[BOTTOM];
        sides[SOUTH] = old_sides[TOP];
        sides[EAST] = prime(old_sides[EAST]);
        sides[WEST] = prime(old_sides[WEST]);
    $incoming.animation = "moving";
    $incoming.playing = true;
    $incoming.frame = get_start_frame(old_sides[NORTH], 4);
    $old.animation = "moving";
    $old.visible = true;
    $old.playing = true;
    $old.frame = get_start_frame(old_sides[TOP], 2);
    $passenger.visible = false;
    $passenger.playing = false;

func move_direction(direction):
    if not $"..".legal_move(direction):
        abort_frames = 1;
        self.frame = 0;
    match direction:
        UP:
            move_up()
        RIGHT:
            move_right()
        DOWN:
            move_down()
        LEFT:
            move_left()

func move():
    if Input.is_action_just_pressed("restart"):
        emit_signal("restart_level")
    elif(lockout):
        if($base.frame > 0):
            if Input.is_action_just_pressed("right"): queued = RIGHT;
            if Input.is_action_just_pressed("up"): queued = UP;
            if Input.is_action_just_pressed("left"): queued = LEFT;
            if Input.is_action_just_pressed("down"): queued = DOWN;
    elif Input.is_action_just_pressed("right") || queued == RIGHT:
        move_direction(RIGHT)
    elif Input.is_action_just_pressed("up") || queued == UP: 
        move_direction(UP)
    elif Input.is_action_just_pressed("left") || queued == LEFT:
        move_direction(LEFT)
    elif Input.is_action_just_pressed("down") || queued == DOWN: 
        move_direction(DOWN)
            
func _process(_delta):
    var old_outline_sound = outline_sound;
    if($exit.visible):
        $"../Camera".shake = 1;
    move();
    if Input.is_action_just_pressed("toggle_indicator"):
        #exit()
        indicator_lock = !indicator_lock;
        if indicator_lock:
            outline_sound = 1;
        else:
            outline_sound = 0;
    if (Input.is_action_pressed("indicator") || indicator_lock) && !lockout:
        if(!$indicator.visible):
            $indicator/east.frame = 0;
            $indicator/north.frame = 0;
            $indicator/west.frame = 0;
            $indicator/south.frame = 0;
            if(Input.is_action_just_pressed("indicator")): outline_sound = 1;
        $indicator.visible = true;
    else:
        if(!Input.is_action_pressed("indicator") && !indicator_lock):
            outline_sound = -1;
        if($indicator.visible && !lockout):
            outline_sound = 0;
        $indicator.visible = false;
    $base.visible = (!$indicator.visible && !$exit.visible);
    #$old.visible = !$indicator.visible;
    $incoming.visible = !$indicator.visible;
    $passenger.visible = !$indicator.visible;
    if($exit.frame > 5):
        $passenger.visible = false;
        #$top.visible = false;
        $incoming.visible = false;
    if($indicator.visible):
        $side_east.frame = side_indices[sides[EAST]];
        $side_north.frame = side_indices[sides[NORTH]];
        $side_west.frame = side_indices[sides[WEST]];
        $side_south.frame = side_indices[sides[SOUTH]];
        $side_east.visible = $indicator/east.visible;
        $side_north.visible = $indicator/north.visible;
        $side_west.visible = $indicator/west.visible;
        $side_south.visible = $indicator/south.visible;
    else:
        $side_east.visible = false;
        $side_north.visible = false;
        $side_west.visible = false;
        $side_south.visible = false;
    if(old_outline_sound != outline_sound && outline_sound >= 0 && !lockout):
        var sound = Sound.instance();
        sound.volume_db = -2;
        if(outline_sound == 1):
            sound.stream = outline_on;
        else:
            sound.stream = outline_off;
        $"..".add_child(sound);

func exit():
    $exit.visible = true;
    $exit.frame = 0;
    $exit.playing = true;
    $base.visible = false;
    var sound = Sound.instance();
    #sound.volume_db = -8;
    sound.stream = exit;
    $"..".add_child(sound);

func _on_base_animation_finished():
    if(abort_frames == -1): 
        var direction;
        if($base.animation == "left"): 
            position.x -= 17;
            direction = LEFT;
        if($base.animation == "right"): 
            position.x += 17;
            direction = RIGHT;
        if($base.animation == "up"): 
            position.y -= 13
            direction = UP;
        if($base.animation == "down"): 
            position.y += 13;
            direction = DOWN;
        if($base.animation != "idle"):
            emit_signal("die_move", direction);
            var sound = Sound.instance();
            sound.volume_db = -8;
            sound.stream = flips[randi() % flips.size()];
            $"..".add_child(sound);
    $base.animation = "idle";
    $base.frame = 0;
    lockout = false;
    $old.playing = false;
    $old.flip_h = false;
    $old.visible = false;
    $passenger.visible = true;
    $passenger.animation = "side";
    $passenger.frame = side_indices[sides[SOUTH]];
    $passenger.playing = false;
    $passenger.flip_h = false;
    $incoming.animation = "top";
    $incoming.flip_h = false;
    $incoming.frame = side_indices[sides[TOP]];
    $incoming.playing = false;

func _on_Die_animation_finished():
    if(abort_frames >= 0): abort_frames -= 1;
    if(abort_frames == 0):
        _on_base_animation_finished();
        abort_frames = -1;

func _on_restart_level():
    reset_state()
    position = Vector2(0, 0)

func _on_exit_animation_finished():
    if($exit.visible):
        emit_signal("level_won");
