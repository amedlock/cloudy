extends Node2D

var  tile_types = {
	"none": Vector2(2,3) , 
	"mountain": Vector2(4,0),
	"grey": Vector2(0,0),
	"blue": Vector2(1,0),
	"red": Vector2(3,0),
	"purple": Vector2(2,0),
	"unknown": Vector2(5,0),
	"house": Vector2(6,0),
	"grave": Vector2(7,0),
	"grass": Vector2(2,2),
	"forest": Vector2(0,1),
	"forest2": Vector2(1,1),
	"wall": Vector2(1,2),
	"gate": Vector2(2,2),	
	"riverN": Vector2(2,1),
	"riverE": Vector2(3,1),
	"riverSW": Vector2(4,1),
	"riverSE": Vector2(5,1),
	"riverNE": Vector2(6,1),
	"riverNW": Vector2(7,1)	
	}


var  items = {
	"axe" : Vector2(4,2),
	"boat" : Vector2(5,2),
	"key" : Vector2(6,2),
	"crown" : Vector2(7,2)
	}


var map_cell = preload("res://game/map/MapCell.tscn")

var grid = []

var cols = 20
var rows = 16

const TileSize = Vector2(32,32)
const HalfTileSize = TileSize * 0.5;

onready var map_mode  = get_parent();

func _ready():
	pass

func resize( xsize, ysize ):
	for g in grid:
		self.remove_child( g )
		g.queue_free()
	grid.clear()
	cols = xsize
	rows = ysize
	grid.resize( cols * rows )
	for x in cols:
		for y in rows:
			var t = map_cell.instance()
			t.tile_type = "none"
			t.xp = x
			t.yp = y			
			t.position = Vector2(32 * x, 32 * y) + HalfTileSize
			grid[x + (y * cols)] = t
			self.add_child( t )			
			
	


func update_tile( t ):
	if t:
		if t.tile_type=="final": return 
		var kind = t.tile_type
		if kind==null:  
			kind = "none"
		if (not t.seen) and t.is_dungeon():
			kind = "unknown"
		t.region_rect.position = tile_types[kind] * 32
			

func reveal( x, y ):
	var t = at( x, y )
	if t:
		t.seen = true
		update_tile( t )

	
func set_tile( x, y, kind ):
	var t = self.at(x,y)
	if t:
		t.tile_type = kind
		update_tile( t )

func at( x, y ):
	var i = x + (y * cols)
	if i >= grid.size():
		return null
	return grid[i]
	
	
func find_empty( y ):
	var result = []
	for x in range(2, get_parent().GridWidth-2 ):
		var on_edge = (x < 5) or ( x > get_parent().GridWidth-5 )
		if y<2 && on_edge: 
			continue;
		if y>(get_parent().GridHeight-2) and on_edge:
			continue;
		var t = self.at(x, y);
		if t.is_empty(): 
			result.append(t);
	return result;
	
	
	
	
