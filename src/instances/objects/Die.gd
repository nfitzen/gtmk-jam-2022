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
enum {UP, RIGHT, DOWN, LEFT}
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
    return 1 + side_indices[side] * 54 + (8 - transition) * 6;

func move_left():
    queued = -1;
    lockout = true;
    $base.frame = 0;
    $base.animation = "left";
    var old_sides = [] + sides;
    sides[TOP] = old_sides[EAST];
    sides[BOTTOM] = old_sides[WEST];
    sides[NORTH] = prime(old_sides[NORTH]);
    sides[SOUTH] = prime(old_sides[SOUTH]);
    sides[EAST] = old_sides[BOTTOM];
    sides[WEST] = old_sides[TOP];
    $incoming.animation = "moving";
    $incoming.flip_h = true;
    $incoming.playing = true;
    $incoming.frame = get_start_frame(prime(sides[TOP]), 5);
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
    sides[TOP] = old_sides[WEST];
    sides[BOTTOM] = old_sides[EAST];
    sides[NORTH] = prime(old_sides[NORTH]);
    sides[SOUTH] = prime(old_sides[SOUTH]);
    sides[EAST] = old_sides[TOP];
    sides[WEST] = old_sides[BOTTOM];
    $incoming.animation = "moving";
    $incoming.playing = true;
    $incoming.frame = get_start_frame(sides[TOP], 5);
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
    sides[TOP] = old_sides[SOUTH];
    sides[BOTTOM] = old_sides[NORTH];
    sides[NORTH] = old_sides[TOP];
    sides[SOUTH] = old_sides[BOTTOM];
    sides[EAST] = prime(old_sides[EAST]);
    sides[WEST] = prime(old_sides[WEST]);
    $incoming.animation = "moving";
    $incoming.playing = true;
    $incoming.frame = get_start_frame(sides[TOP], 3);
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
    sides[TOP] = old_sides[NORTH];
    sides[BOTTOM] = old_sides[SOUTH];
    sides[NORTH] = old_sides[BOTTOM];
    sides[SOUTH] = old_sides[TOP];
    sides[EAST] = prime(old_sides[EAST]);
    sides[WEST] = prime(old_sides[WEST]);
    $incoming.animation = "moving";
    $incoming.playing = true;
    $incoming.frame = get_start_frame(sides[TOP], 4);
    $old.animation = "moving";
    $old.visible = true;
    $old.playing = true;
    $old.frame = get_start_frame(old_sides[TOP], 2);
    $passenger.visible = false;
    $passenger.playing = false;

func move_direction(direction):
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
    if(lockout):
        if($base.frame > 0):
            if Input.is_action_just_pressed("right"): queued = 0;
            if Input.is_action_just_pressed("up"): queued = 1;
            if Input.is_action_just_pressed("left"): queued = 2;
            if Input.is_action_just_pressed("down"): queued = 3;
        return;
    if Input.is_action_just_pressed("right") || queued == 0:
        move_direction(RIGHT)
    elif Input.is_action_just_pressed("up") || queued == 1: 
        move_direction(UP)
    elif Input.is_action_just_pressed("left") || queued == 2:
        move_direction(LEFT)
    elif Input.is_action_just_pressed("down") || queued == 3: 
        move_direction(DOWN)

func _process(_delta):
    move();

func _on_base_animation_finished():
    if($base.animation == "left"): position.x -= 17;
    if($base.animation == "right"): position.x += 17;
    if($base.animation == "up"): position.y -= 13
    if($base.animation == "down"): position.y += 13;
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
