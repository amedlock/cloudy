extends Sprite

var  grid_x = 0
var  grid_y = 0

	
func contains_point( p ):
	return Rect2( position, Vector2( 64, 64 ) ).has_point( p )	