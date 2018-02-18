extends KinematicBody2D

var kind = "demon" 

var health = 3
var speed = 210
var damage = 40

var state = "sleep"
var path = []

signal died 

func _ready():
	self.kind = "demon"
	self.health = 4

func warn():
	pass

func alert():
	state ="alert"
	path =[]

func wait():
	self.state = "wait"

func awaken():
	self.state = "search"

func die():
	self.emit_signal("died" , self )

func sleep():
	self.state = "wait"
	self.path =[]


func hit(other):
	if other.kind=="arrow":
		self.health-= 1
		other.queue_free()
		get_parent().add_blood( self )
		if state=="sleep": state = "chase"
		if self.health < 0:
			self.die()
			


