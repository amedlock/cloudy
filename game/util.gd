
class Random:
	var cur_seed = 0
	
	func next_float():
		return randf()
	
	func next_int():
		rand_seed(cur_seed)
		return randi()
		
	func next_bool():
		return next_int() > 0x80000000 / 2
		
	func rand_int( lo, hi ):
		if lo==hi: return lo
		var val = next_int() % (hi - lo)
		return lo + val;

	func choice( items ):
		if items==null or items.empty():
			return null
		return items[ self.rand_int( 0, items.size()-1 ) ]


	func shuffle(items):
		var result = []
		var indices = range( items.size() )
		while not indices.empty():
			var n = rand_int( 0, indices.size() - 1 )
			var value = indices[n]
			indices.remove( n )
			result.append( items[value] )
		return result

static func make_random( rseed ):
	var r = Random.new()
	r.cur_seed = rseed
	return r

static func choice( items ):
		if items==null or items.empty():
			return null
		return items[ randi() % items.size() ]

static func shuffle( items ):
		if items==null or items.empty():
			return []
		return make_random( randi() ).shuffle( items )


static func between( val, lo, hi ):
	return val >= lo and val <= hi;



# helper for a 2D Grid of cells laid over a higher resolution
# coord means grid coord, pos means world position, index is in range(width*height)
class GridUtil:
	var width = 8
	var height = 8
	var cell_size = 32

	func valid( x, y ):
		return x>=0 and y>=0 and x< width and y < height 

	func coord_to_pos( x, y ): 
		return Vector2(x * cell_size, y * cell_size )

	func coord_to_center( x, y ): 
		return coord_to_pos(x,y) + Vector2( cell_size/2 , cell_size / 2)

	func pos_to_coord( x, y ):
		return Vector2( int(x/cell_size), int(y/cell_size) )

	func coord_to_index( x, y ):
		return int( x + (y * width))

	func index_to_coord( index ):
    	return Vector2( int(index % width), int(index/width) )
	
	func coord_contains_pos( x, y, pos ):
		var p = coord_to_pos(x,y)
		if pos.x < p.x or pos.y < p.y: return false
		return ( pos.x - p.x < cell_size ) and ( pos.y - p.y < cell_size )
	
	func coord_to_world_rect( x, y ):
		var p = coord_to_pos(x ,y )
		return Rect2( p, Vector2( cell_size, cell_size ) )
  
	func pos_to_index( x, y ):
		var c = pos_to_coord(x, y )
		return coord_to_index( c.x, c.y )

	# find all coords near coord(x,y) with radius r
	func coord_near( x, y, r=1 ):
		var result = []
		for dx in range(-r, r ):
			for dy in range( -r, r ):
				if dx==x and dy==y: # dont include orig
					continue
				if valid( dx+x, dy+y ):
					result.append( Vector2( x+dx, y+dy ) )
		return result
		
	func coord_neighbors( x, y ):
		var result = []
		if valid( x-1,y ): result.append( Vector2( x-1,y ) )
		if valid( x+1,y ): result.append( Vector2( x+1,y ) )
		if valid( x,y-1 ): result.append( Vector2( x,y-1 ) )
		if valid( x,y+1 ): result.append( Vector2( x,y+1 ) )
		return result


static func make_grid( width, height, cell_size  ):
  var result = GridUtil.new()
  result.width = width
  result.height = height
  result.cell_size = cell_size
  return result


# this is probably overkill
static func free_children( p ):
	if p==null: return
	while p.get_child_count():
		var ch = p.get_child( 0 )
		p.remove_child( ch )
		ch.queue_free()
		
			

	
	

