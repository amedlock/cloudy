extends KinematicBody2D


var kind = "rat" 
var health = 2
var damage = 30;
var speed = 200

var state = "sleep"
var path = []


var warn_sound = null
var roar_sound = preload("res://assets/rat.wav")


signal died 


func _ready():
	$Timer.wait_time = 2
	$Timer.one_shot = true
	$Timer.connect("timeout", self, "play_sound" )


func warn():
	pass

func awaken():
	if state!="sleep":
		return
	state = "search"
	$Audio.stop()
	$Audio.stream = roar_sound
	$Timer.stop()
	$Timer.one_shot = false
	$Timer.wait_time = 1
	$Timer.start()


func play_sound():
	$Audio.play()

func wait():
	self.state = "wait"
	$Timer.stop()
	$Audio.stop()

func die():
	self.emit_signal("died" , self )

func sleep():
	state = "sleep"
	$Audio.stop()
	$Timer.stop()
	self.path =[]


func alert():
	state ="alert"
	$Timer.stop()
	path =[]
	

func hit(other):
	if other.kind=="arrow":
		self.health-= 1
		other.queue_free()
		get_parent().add_blood( self )
		if state=="sleep": state = "chase"
		if self.health < 0:
			self.die()


	

