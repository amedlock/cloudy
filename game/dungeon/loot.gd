extends Area2D

var kind = "Unknown"

func _ready():
	self.connect( "body_entered", self, "entered" )
	self.connect( "body_exited" , self, "exited" )


func entered( d ):	
	if d.kind=="player":
		d.touching = self

func exited( d ):
	if d.kind=="player" and d.touching==self:
		d.touching = null		
		
