extends Node2D

const Util = preload("../util.gd")

var random;


onready var player = $Player

const Width = 8 	# width of map grid
const Height = 8 	# height of map grid
const CellSize = 192 # each map cell is CellSize x CellSize
const FogPerCell = 3


var  mazegen 
var dark ;
var astar
var tiles

var initialized = false


func _ready():
	player.connect("died", self, "player_died" )
	player.connect("fired", $Enemies, "heard_shot" )
	tiles = $Tiles
	if !initialized:
		initialized = true
		random = Util.Random.new()
		astar = AStar.new()
		tiles.init( Width, Height, CellSize )
		$Dark.init( FogPerCell * Width, FogPerCell * Height, 192 / FogPerCell )
		add_fog()		
		mazegen = preload("res://game/dungeon/mazegen.gd").new()
		mazegen.init( Width, Height, random )
		
		
	

func _input(event):
	if event is InputEventKey and event.scancode==KEY_F12:
		exit_dungeon()
	if event is InputEventKey and event.scancode==KEY_F11:
		get_parent().lost_game()
	if event is InputEventKey and event.scancode==KEY_F10:
		get_tree().quit()


func _process(delta):
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.state=="sleep":
			var dist = player.position.distance_to( e.position ) 
			if dist < 192:
				e.warn()
			

func exit_dungeon():
	get_parent().exit_dungeon(player)

func won_game():
	get_parent().won_game()

func lost_game():
	get_parent().lost_game()



var Fog = preload("res://game/dungeon/fog.tscn")


func add_fog():
	for x in range( $Dark.width ):
		for y in range( $Dark.height ):
			var f = Fog.instance()
			$Dark.set_node( x, y, f )


func show_fog():
	for f in $Dark.get_children():
		f.visible = true



func remove_fog( x, y ):
	if $Dark.valid( x, y):
		var c = $Dark.at(x,y)
		if c.node.visible:
			c.node.visible = false
			for e in $Enemies.all_enemies():
				if c.contains_pos( e.position ):
					e.awaken()


func shadows_inside_map_cell( cx, cy ):
	var result = []
	for x in range( 3 ):
		for y in range( 3 ):
			var sx = (cx * 3) + x
			var sy = (cy * 3) + y
			var d = $Dark.at( sx, sy )
			if d.node.visible==true:
				result.append( d )
	return result


func reveal():
	var p = player.position
	var pc = tiles.pos_to_coord( p ) # pc = dungeon grid coord (8x8)
	var revealed = []
	for s in shadows_inside_map_cell( pc.x, pc.y ):
		if s.node.visible:
			s.node.visible = false
			revealed.append( s )
	for p2 in mazegen.paths_from( pc.x, pc.y ):
		for s2 in shadows_inside_map_cell ( p2.x, p2.y ):
			var n = s2.node
			if n.position.distance_to( player.position ) < 90:
				n.visible = false
				revealed.append( s2 )
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.state=="sleep": 
			for f in revealed:
				if f.contains_point( e.position ):
					e.awaken()

	

var caveNSEW = preload("res://game/dungeon/caveNSEW.tscn")
var caveSEW = preload("res://game/dungeon/caveSEW.tscn")
var caveEW = preload("res://game/dungeon/caveEW.tscn")
var caveSE = preload("res://game/dungeon/caveSE.tscn")
var caveS = preload("res://game/dungeon/caveS.tscn")




func is_hall( cell ):
	if cell.count()!=2: 
		return false
	return (cell.left and cell.right) or (cell.up and cell.down )

func select_cave( cell ):
	if cell.count()==4:
		return caveNSEW.instance()
	elif cell.count()==1:
		var result = caveS.instance()
		if cell.up:
			result.rotation_degrees = 180
		elif cell.right:
			result.rotation_degrees = 270
		elif cell.left:
			result.rotation_degrees = 90
		return result
	elif cell.count()==3:
		var result = caveSEW.instance()
		if not cell.right:
			result.rotation_degrees = 90
		elif not cell.left:
			result.rotation_degrees = 270
		elif not cell.down:
			result.rotation_degrees = 180
		else:
			assert( not cell.up )
		return result
	elif is_hall( cell ):
		var result = caveEW.instance()
		if cell.up!=null:
			assert( cell.down )
			result.rotation_degrees = 90
		else:
			assert( cell.left and cell.right )			
		return result
	else:   
		var result = caveSE.instance()
		if not cell.up:
			if not cell.right:
				result.rotation_degrees = 90
			return result
		elif not cell.right:
			if not cell.down:
				result.rotation_degrees = 180
			return result
		else:
			assert( not cell.left )
			if not cell.down:
				result.rotation_degrees = 270
			return result


func add_cave( cell ):
	var node = select_cave( cell )
	if node!=null:
		tiles.set_node(cell.x, cell.y, node, true )


func create_nav():
	astar.clear()
	for n in range( 0, 64 ):
		var gx = int(n % Width)
		var gy = int(n / Width)
		astar.add_point( n, Vector3( gx , gy , 0 ) )
	for n in range( 0, 64):
		var gx = int(n % Width)
		var gy = int(n / Width)
		var cell = mazegen.at( gx, gy )
		if cell.right!=null: 
			astar.connect_points( cell.index, cell.right.index, true )
		if cell.down: 
			astar.connect_points( cell.index, cell.down.index, true )



func calc_nav_path( first, last ):
	var result = []
	var midpt = Vector2( 96, 96 )
	for p in astar.get_point_path( first, last ):
		result.append( Vector2( p.x * 192 , p.y * 192 ) + midpt )
	return result


func start_dungeon(kind,p):
	player.lives = p.lives
	player.camera.make_current()
	tiles.free_nodes()
	Util.free_children( $Items )
	Util.free_children( $Enemies )
	show_fog()
	mazegen.generate( 2,2 )
	create_nav()
	for mx in range( Width ):
		for my in range( Height ):
			add_cave( mazegen.at( mx, my ) )
	player.reset(CellSize/2, CellSize/2)
	populate_dungeon(kind)
	play_sound( "res://assets/enter.wav" )


func sleep_monsters():
	for e in $Enemies.all_enemies():
		e.sleep()


func play_sound( snd, bus="Master" ):
	$Audio.bus = bus
	$Audio.stream = load( snd )
	$Audio.play()


var bat = preload("res://game/enemy/bat.tscn")
var rat = preload("res://game/enemy/rat.tscn")	
var demon = preload("res://game/enemy/demon.tscn")	
var snake = preload("res://game/enemy/snake.tscn")	
var dragon = preload("res://game/enemy/dragon.tscn")	
var winged = preload("res://game/enemy/winged.tscn")	

var loot = preload( "res://game/dungeon/loot.tscn" )
	


var monster_trax = {
		"rat": Vector2(2,2) * 32,
		"demon": Vector2(3,2) * 32,
		"snake" : Vector2(1,2) * 32
	};

	
var Tracks = preload("res://game/dungeon/tracks.tscn")
	

func add_tracks_at( x, y, rr ):
	var s = Tracks.instance()
	s.region_rect.position = rr
	s.position = Vector2( x , y )
	$Items.add_child( s )
			
	
var item_sprite = {
	"quiver": Vector2(0,1),
	"crown1": Vector2(1,1),
	"crown2": Vector2(2,1),
	"ladder": Vector2(0,2),
	"boat": Vector2( 1,6 ),
	"axe": Vector2( 0,6),
	"key": Vector2( 2,6),
	"crown": Vector2( 3,6 ),
	"skull": Vector2(1, 2 )
	}

func make_item( item_name ):
	var it = loot.instance()
	it.kind = item_name 
	it.get_node("Sprite").region_rect.position = item_sprite[item_name] * 32
	return it


func connected_tiles( x, y ):
	var result = []
	for n in tiles.nearby_cells( x, y ):
		var c2 = n.coord
		if mazegen.has_path( x, y, c2.x, c2.y ):
			result.append( tiles.at( c2.x, c2.y ) )
	return result
		

func add_bat( area ):
	var cell = tiles.at_index( area )
	var b = bat.instance()
	b.position = cell.center()
	b.connect("died", self, "add_smoke" )
	$Enemies.add_child( b )
	

func add_monster( prefab, area, item_name ):
	var dc = tiles.index_to_coord( area ) 
	var pos = tiles.at( dc.x, dc.y ).center()
	var m = prefab.instance()	
	m.add_to_group("enemy")
	$Enemies.add_child( m )
	m.connect("died", self, "add_smoke" )	
	m.position = pos
	var item = make_item( item_name )	
	$Items.add_child( item )
	item.position = pos
	if monster_trax.has( m.kind ):
		for nc in mazegen.paths_from( dc.x, dc.y):  # nc is a dungeon coord
			var cell2 = tiles.at( nc.x, nc.y ).center()
			add_tracks_at( cell2.x, cell2.y,  monster_trax[m.kind]  )


var smoke = preload("res://game/enemy/smoke.tscn")

func add_smoke( m ):
	var s = smoke.instance()
	self.add_child( s )
	s.position = m.position
	m.queue_free()

	
func player_died():
	for e in $Enemies.all_enemies():
		e.wait()
	player.lives -= 1
	player.pause_mode
	var s = smoke.instance()
	self.add_child( s )
	s.position = player.position
	if player.lives==0:
		s.connect("done", get_parent(), "lost_game" )
	else:
		s.connect("done", self, "next_life" )
	
func next_life():
	player.reset( 96, 96 )
	for e in $Enemies.all_enemies():
		if e.state!="sleep":
			e.alert()
	
	
func place_monsters(areas, kind):
	areas.erase( 0 )
	areas.erase( 1 )
	areas.erase( Width )
	areas.erase( Width+1 )
	add_bat( Width * (Height-1) )
	add_bat( (Width * Height ) - 1 )
	if kind=="grey":
		add_monster( rat, areas.pop_back(), "quiver"  )
		add_monster( rat, areas.pop_back(),  "ladder" )
		add_monster( snake, areas.pop_back(), "quiver" )
	elif kind=="blue":
		add_monster( demon, areas.pop_back(), "boat" )
		add_monster( demon, areas.pop_back(), "ladder" )
		add_monster( dragon, areas.pop_back(), "quiver" )
	elif kind=="red":
		add_monster( snake, areas.pop_back(), "axe" )
		add_monster( snake, areas.pop_back(), "ladder" )
		add_monster( rat, areas.pop_back(), "quiver" )
	elif kind=="purple":
		add_monster( dragon, areas.pop_back(), "key" )
		add_monster( dragon, areas.pop_back(), "ladder" )
		add_monster( demon, areas.pop_back(), "quiver" )
	elif kind=="final":
		add_monster( winged, areas.pop_back(), "crown1" )
		add_monster( winged, areas.pop_back(), "crown2" )
		add_monster( dragon, areas.pop_back(), "quiver" )


func populate_dungeon( kind ):
	var areas = Util.shuffle( range(1,64) ) # 0 = player start area
	place_monsters(areas,kind)
