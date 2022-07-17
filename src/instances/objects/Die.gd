extends Node2D

var lockout : bool = false;
var queued : int = -1;
enum {
    TOP,
    BOTTOM,
    NORTH,
    SOUTH,
    EAST,
    WEST,
   }
var sides = ["6", "1", "3", "4", "5", "2"];
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

func prime(inp : String):
    if(inp == "1" || inp == "4" || inp == "5"): return inp;
    if(inp.substr(1, 2) == "p"): return inp.substr(0, 1);
    return inp + "p";
    
func get_start_frame(side : String, transition : int):
    return 1 + side_indices[side] * 54 + transition * 6;

func move_left():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "left";
    var old_sides = sides;
    sides[TOP] = old_sides[EAST];
    sides[BOTTOM] = old_sides[WEST];
    sides[NORTH] = prime(old_sides[NORTH]);
    sides[SOUTH] = prime(old_sides[SOUTH]);
    sides[EAST] = old_sides[BOTTOM];
    sides[WEST] = old_sides[TOP];
    $incoming.playing = true;
    $incoming.frame == get_start_frame(sides[TOP], 4);
    
func move_right():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "right";
    var old_sides = sides;
    sides[TOP] = old_sides[WEST];
    sides[BOTTOM] = old_sides[EAST];
    sides[NORTH] = prime(old_sides[NORTH]);
    sides[SOUTH] = prime(old_sides[SOUTH]);
    sides[EAST] = old_sides[TOP];
    sides[WEST] = old_sides[BOTTOM];
    $incoming.playing = true;
    $incoming.frame == get_start_frame(sides[TOP], 3);
    
func move_up():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "up";
    var old_sides = sides;
    sides[TOP] = old_sides[SOUTH];
    sides[BOTTOM] = old_sides[NORTH];
    sides[NORTH] = old_sides[TOP];
    sides[SOUTH] = old_sides[BOTTOM];
    sides[EAST] = prime(old_sides[EAST]);
    sides[WEST] = prime(old_sides[WEST]);
    $incoming.playing = true;
    $incoming.frame == get_start_frame(sides[TOP], 5);
    
func move_down():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "down";
    var old_sides = sides;
    sides[TOP] = old_sides[NORTH];
    sides[BOTTOM] = old_sides[SOUTH];
    sides[NORTH] = old_sides[BOTTOM];
    sides[SOUTH] = old_sides[TOP];
    sides[EAST] = prime(old_sides[EAST]);
    sides[WEST] = prime(old_sides[WEST]);
    $incoming.playing = true;
    $incoming.frame == get_start_frame(sides[TOP], 5);

func move():
    if(lockout):
        if($base.frame > 0):
            if Input.is_action_just_pressed("right"): queued = 0;
            if Input.is_action_just_pressed("up"): queued = 1;
            if Input.is_action_just_pressed("left"): queued = 2;
            if Input.is_action_just_pressed("down"): queued = 3;
        return;
    if Input.is_action_just_pressed("right") || queued == 0:
        move_right();
        return;
    if Input.is_action_just_pressed("up") || queued == 1: 
        move_up();
        return;
    if Input.is_action_just_pressed("left") || queued == 2:
        move_left();
        return;
    if Input.is_action_just_pressed("down") || queued == 3: 
        move_down();
        return;

func _process(_delta):
    move();

func _on_base_animation_finished():
    if($base.animation == "left"): position.x -= 17;
    if($base.animation == "right"): position.x += 17;
    if($base.animation == "up"): position.y -= 13
    if($base.animation == "down"): position.y+= 13;
    $base.animation = "idle";
    $base.frame = 0;
    lockout = false;
    $top.playing = false;
    $passenger.playing = false;
    $incoming.playing = false;
