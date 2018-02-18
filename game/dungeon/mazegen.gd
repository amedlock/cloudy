extends Object

enum { None , Frontier, Visited  }


class Cell:
	var x = 0
	var y = 0
	var index = 0
	var up = null
	var down = null
	var left = null
	var right = null
	var state = None

	func reset():
		state = None
		up = null
		down = null
		left = null
		right = null
	
	func count():
		var total = 0
		if up: total += 1
		if down: total += 1
		if left: total += 1
		if right:total += 1
		return total
	
	func str():
		return String(x) + "," + String(y)
	

var random
var Width
var Height

var block = []

var marked = 0

func valid( x, y ):
	return x >=0 and x < Width and y >=0 and y < Height

func init( w, h, r ):
	block.clear()
	block.resize( w * h )
	Width = w
	Height = h
	random = r
	for x in range(w):
		for y in range( h ):
			var n = x + (y * w)
			var c = Cell.new()
			c.x = x
			c.y = y
			c.index = n
			block[n] = c

const directions = [ Vector2(0,1), Vector2(1,0), Vector2(0,-1), Vector2(-1,0) ]


func at( x, y ):
	return block[x + (y * Width)]

func mark( x, y, near ):
	var c = at(x,y)
	if c.state==Frontier:
		near.erase( c )
	c.state = Visited
	marked += 1
	for d in directions:
		var sx = x + d.x
		var sy = y + d.y
		if not valid( sx, sy ):
			continue
		var f = at( sx, sy )
		if f.state==None:
			f.state = Frontier
			near.append( f )


func find_maze_cell( c ):
	var items = []
	for d in directions:
		var x = c.x + d.x
		var y = c.y + d.y
		if not valid( x, y ):
			continue
		var c2 = at( x, y )
		if c2.state==Visited:
			items.append( c2 )
	return random.choice( items )
	

func open_path( p, p2 ):
	if p.x < p2.x:
		p.right = p2
		p2.left = p	
	elif p.x > p2.x:
		p.left = p2
		p2.right = p
	elif p.y < p2.y:
		p.down = p2
		p2.up = p
	elif p.y > p2.y:
		p.up = p2
		p2.down = p


func generate( sx, sy ):
	marked = 0
	for b in block:  b.reset()
	var near = []		
	mark( sx, sy, near )
	var total = Width * Height	
	while not near.empty():
		var cur = random.choice( near )
		assert( cur!=null )
		mark( cur.x, cur.y, near )
		var c2 = find_maze_cell( cur )
		assert( c2!=null and c2.state==Visited )
		open_path( cur, c2 )


func has_path( x, y, x2, y2 ):
	if valid(x,y) and valid(x2,y2):
		var c1 = at( x, y )
		var c2 = at( x2, y2 )
		if c1.y==c2.y:
			if c1.x < c2.x:
				return c1.right!=null
			else:
				return c1.left!=null
		elif c1.x==c2.x:
			if c1.y < c2.y:
				return c1.down!=null
			else:
				return c1.up!=null
		else:
			return false


# return all connected cells neighboring this one  
func paths_from( x, y ):
	var cell = self.at( x, y )
	var result = []
	if cell!=null:
		if cell.up!=null: 
			result.append( Vector2(x,y-1) )
		if cell.down!=null: 
			result.append( Vector2(x,y+1) )
		if cell.left!=null: 
			result.append( Vector2(x-1,y) )
		if cell.right !=null: 
			result.append( Vector2(x+1,y) )
	return result


