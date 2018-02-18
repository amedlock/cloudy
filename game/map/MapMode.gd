extends Node2D

const Util = preload("../util.gd")

onready var grid = $Tiles

var random = null
var map_seed = 0

var player ;

var game_state = "playing"


const GridWidth = 20
const GridHeight = 16

var initialized = false


func _ready():
	player = $Player
	$Audio.bus = "Master"
	if !initialized:
		initialized = true
		randomize()
		random = Util.make_random( randi() )
		grid.resize( 20 , 16 )
		grid.at( 18, 7 ).tile_type = "final"
		grid.at( 19, 7 ).tile_type = "final"
		create_map()
		grid.set_tile( 0, 7, "house" )
		player.lives = 3 
		player.x = 0
		player.y = 7
		move_player( 0, 0 )
	



func generate_river(x):
	var y1 = 0
	var y2 = GridHeight-1;
	if random.rand_int(1,10) >6: # river stops halfway
		y2 = y2 / 2
		if random.next_bool():
			y1 = GridHeight / 2
			y2 = GridHeight - 1
	if y1 > 0: grid.set_tile( x, y1-1, "mountain" )
	var quarter = GridHeight / 4
	var turn = random.rand_int( quarter, quarter * 3 )
	var turn_size = random.rand_int( 2, 4 )
	while y1 <= y2:
		if y1==turn:
			grid.set_tile( x, y1, "riverNE" )
			var dir = 1
			if random.next_bool(): 
				dir = -1
				grid.set_tile( x, y1, "riverNW" )
			for rx in range(1,turn_size):
				grid.set_tile( x+(rx * dir), y1, "riverE" )
			x = x + (turn_size*dir)
			if dir<0:
				grid.set_tile( x, y1, "riverSE" )
			else:
				grid.set_tile( x, y1, "riverSW" )
			y1 += 1
		else:
			grid.set_tile( x, y1, "riverN" )
			y1 += 1
		


func generate_wall(pos):
	var x = pos; #random.rand_int(6, GridWidth-7)
	var y = GridHeight/2
	var y2 = GridHeight-1
	if random.next_bool():
		var tmp= y;
		y = 0; 
		y2 =tmp;
	while x < GridWidth and grid.at(x,y).tile_type!="none":
		x+= 1
	if x > GridWidth-3:
		return	
	var gate_pos = random.rand_int(y, y2)
	while y < y2:
		var t = grid.at(x, y)
		if t.tile_type!="none":
			break
		if y==gate_pos:
			grid.set_tile( x, y, "gate" )
		else:
			grid.set_tile( x, y, "wall" )
		y+=1;
	for dy in range( y, y+5 ):
		if dy >= GridHeight: break
		if grid.at( x, dy ).is_empty():
			grid.set_tile( x, dy, "mountain" )


func add_forest( x,  y, radius ) :
	for y1 in range( y-radius, y+radius ):
		for x1 in range( x-radius, x + radius ):
			if x1 < 3 or x1 > GridWidth-3:
				continue;
			var L = abs(x-x1) + abs(y-y1);
			if L > radius: 
				continue;
			var t = grid.at(x1, y1)
			if t.tile_type!="none":
				continue;
			if random.rand_int(1, 5) > 3: 
				continue;
			grid.set_tile( x1, y1, "forest" )



func generate_forest():
	var count = random.rand_int(1, 3)
	
	while count>0 :
		var rx = random.rand_int(4, GridWidth-4);
		var ry = random.rand_int(4, GridHeight-4);
		var radius = random.rand_int(3, 6);
		add_forest( rx, ry, radius );
		count-=1;


func add_mtn(t):
	var x = t.xp
	var y = t.yp
	var type = random.rand_int(1, 17);
	if y==0 or y==GridHeight-1: 
		type = 8;
	if Util.between(type,1,4): 
		grid.set_tile(x,y, "mountain");
	elif Util.between(type,5,8): 
		grid.set_tile(x,y, "grey");
	elif  Util.between(type,9,12):
		grid.set_tile(x,y, "blue");
	elif Util.between(type,13,15): 
		grid.set_tile(x,y, "red");
	else:
		grid.set_tile(x,y, "purple");


func generate_mtn():
	for y in range( 0, GridHeight-1 ):
		var items = grid.find_empty(y)
		if !items.empty():
			add_mtn( items.pop_front() )
		if !items.empty():
			add_mtn( items.pop_back() )
		if items.empty():
			continue
		items = random.shuffle( items )
		var count = items.size() - 3 ;
		if count < 3: 
			count = items.size();
		while count>0 :
			count-=1;
			add_mtn( items.pop_front() );



func create_map():
	var riverpos = random.rand_int(GridWidth/4, GridWidth * 3 / 4 )
	var wallpos = GridWidth - riverpos;
	if wallpos > 12: wallpos = GridWidth - wallpos
	generate_river(riverpos)
	generate_wall(wallpos)
	generate_forest()
	generate_mtn()


func map_coord( cx, cy ):
	return Vector2( cx * 32, cy * 32 ) + Vector2( 16, 16 )


var move_map = {
		"up": Vector2(0,-1),
		"up_right": Vector2(1,-1),
		"right": Vector2(1,0),
		"down_right": Vector2(1,1),
		"down": Vector2(0,1),
		"down_left": Vector2(-1,1),
		"left": Vector2(-1,0),
		"up_left": Vector2(-1,-1),
	}


func _input(evt):
	if game_state!="playing":
		return
	if evt.is_pressed():
		if false and (evt is InputEventKey):
			if evt.scancode==KEY_F12:
				game_state = "won"
		if evt.is_action("quit"):
			get_tree().quit()
		else:
			for a in move_map:
				if evt.is_action( a ):
					var d = move_map[a]
					move_player( d.x, d.y )
					break
		
	
func reveal_map():
	for dx in [-1,0,1]:
		for dy in [-1,0,1]:
			grid.reveal( player.x + dx, player.y + dy )
				


func move_player( dx, dy ):
	var px = player.x + dx
	var py = player.y + dy
	if px < 0 or px >=GridWidth:
		return
	if py < 0 or py >=GridHeight:
		return
	var t = grid.at( px, py )
	if not t: return
	if t.can_enter( player ):
		player.x += dx
		player.y += dy
		player.position = map_coord( player.x, player.y )
		player.set_icon( t.get_icon() )
		reveal_map()
		if t.is_dungeon() and not t.visited:
			t.visited = true
			get_parent().enter_dungeon( t.tile_type )
	else:
		$Audio.stream = load("res://assets/blocked.wav")
		$Audio.play()
		
		
func _process(delta):
	if game_state=="playing":
		return
	if game_state=="won":
		game_state = "ended"
		player.set_icon("crown")
		get_node( "Tiles/CloudyMtn" ).sound = false
		$Audio.stream = load("res://assets/win.wav")
		$Audio.play()
	elif game_state=="died":
		game_state = "ended"
		get_node( "Tiles/CloudyMtn" ).sound = false
		player.set_icon("grave")

func exit_dungeon(p):
	self.player.update(p)
	$Camera.current = true
