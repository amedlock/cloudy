extends Node2D

var lives = 3

var inventory = []

var x = 0
var y = 0

var  icon = null  # do we show a custom icon in the map?

var  icons = {
	"grave" : Vector2(3,2) * 32,
	0 : Vector2(3,2) * 32,
	1: Vector2(128, 128), 
	2:Vector2(96, 128), 
	3:Vector2(64, 128),
	"axe": Vector2(4,2) * 32,
	"key": Vector2(6,2) * 32,
	"boat": Vector2(5,2) * 32,
	"crown": Vector2( 7,2 ) * 32
	};


func _ready():
	set_icon()
	$Timer.connect("timeout", self, "blink")

	
func blink():
	if inventory.has("crown"):
		visible = true
	else:
		visible = !visible	

func has_item( name ):
	return name in self.inventory
	
func set_icon( i=null ):
	if i==null: i = lives
	if icons.has( i ):
		$Sprite.region_rect.position = icons[i]
		i = icons[ lives ]

		
func update_info( p ):
	self.lives = p.lives
	for x in p.inventory:
		if not self.inventory.has( x ):
			self.inventory.append( x )
	self.set_icon( self.lives )
			