extends Sprite

var tile_type = "none"

var xp = 0
var yp = 0

var required = null
var seen = false
var visited = false


func _ready():
	self.region_rect = Rect2( 64, 96, 32, 32 )
	get_parent().update_tile( self )
	
func is_empty():
	return tile_type in [null, "none"]	

func get_icon():
	if tile_type.begins_with("river"): 
		return "boat"
	elif tile_type=="gate":
		return "key"
	elif tile_type=="forest":
		return "axe"
	else:
		return null
	


func is_dungeon():
	return (tile_type in ["grey", "red", "blue", "purple", "final"] )

	
func can_enter( plyr ):
	if tile_type in [ "mountain", "wall" ]: 
		return false
	elif tile_type=="gate":
		return plyr.has_item("key")
	elif tile_type=="forest":
		return plyr.has_item("axe")
	elif tile_type.begins_with( "river" ):
		return plyr.has_item("boat")
	else:
		return true


