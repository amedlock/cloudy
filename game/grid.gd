extends Node2D

# this script maps a grid coordinate space to world(or pixel) space
# after initialization it keeps a list of wxh cells 

# width and height of grid
var width 
var height 

# each cell in the grid is this size
var cell_size 

# convenience lookup by cell index
var cells = {}


class Cell:
	var coord 
	var pos
	var index = 0
	var size = null
	var node = null

	func contains_point( p ):
		return Rect2( pos, Vector2(size,size) ).has_point( p )

	func center():
		return pos + Vector2( size/2, size/2 ) # dangerous
	

func free_nodes():
	for v in cells.values():
		if v.node==null: 
			continue
		v.node.queue_free()
		self.remove_child( v.node )
		v.node = null		
		


func init( w, h, sz ):
	self.free_nodes()
	cells.clear()
	width = w
	height = h
	cell_size = sz
	for x in width:
		for y in height:
			var c = Cell.new()
			c.coord = Vector2( x, y )
			c.pos = Vector2( x * cell_size, y * cell_size )
			c.index = int( x + (y * w) )
			c.size = cell_size
			cells[ c.index ] = c



func valid( x, y ):
  return x>=0 and x<width and y>=0 and y<height

func all_cells():
	return Array( cells.values() )


func at( x, y ):
	return cells[ int( x + (y * width)) ]

func at_index( n ):
	return cells[ n ]

# returns the cell at position p (world space)
func at_pos(p):
  var c = pos_to_coord(p)
  if valid( c.x, c.y ):
    return at( c.x, c.y )
  else:
    return null


func nearby_cells(x, y):
	var result = []
	if valid( x-1, y ): result.append( at(x-1, y ) )
	if valid( x, y-1 ): result.append( at(x, y-1 ) )
	if valid( x+1, y ): result.append( at(x+1, y ) )
	if valid( x, y+1 ): result.append( at(x, y+1 ) )
	return result


func set_node( x, y, n, center = false ):
	if not valid(x,y):
		return
	var c = at( x, y )
	var prev = c.node
	if prev:
		self.remove_child( prev )
	c.node = n
	if center:
		n.position = c.center()
	else:
		n.position = c.pos
	self.add_child( n )
	return prev


# converts a integer index to grid coords
func index_to_coord(index):
	if cells.has( index ):
		return cells[index].coord

# converts a world space to a grid space coord
func pos_to_coord( p ):
  return Vector2( int(p.x/cell_size), int(p.y/cell_size))


func pos_to_index( p ):
	var c = pos_to_coord( p )
	return at( c.x, c.y ).index




