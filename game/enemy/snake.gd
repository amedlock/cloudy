extends KinematicBody2D

var kind = "snake"

var health = 3
var speed = 220
var damage = 50;
var state = "sleep"
var path = []


var warn_sound = preload("res://assets/snake_warn.wav")
var roar_sound = preload("res://assets/snake.wav")

signal died 


func _ready():
	$Audio.stream = warn_sound
	$Timer.one_shot = true
	$Timer.wait_time = 2
	$Timer.connect("timeout", self, "play_sound" )

func warn():
	if state!="sleep" or $Audio.playing: 
		return 
	if $Timer.is_stopped():
		$Timer.start()

func wait():
	state = "sleep"
	$Timer.stop()
	$Audio.stop()

func awaken():
	if state!="sleep":
		return
	state = "search"
	$Audio.stop()
	$Audio.stream = roar_sound
	$Timer.stop()
	$Timer.one_shot = false
	$Timer.start()

	
	
func alert():
	state ="alert"
	$Audio.stop()
	$Timer.stop()
	path =[]
	
	
func sleep():
	$Audio.stop()
	$Timer.stop()
	state = "sleep"
	self.path =[]

	
func play_sound():
	$Audio.play()

func die():
	self.emit_signal("died" , self )


func hit(other):
	if other.kind=="arrow":
		self.health-= 1
		other.queue_free()
		get_parent().add_blood( self )
		if state=="sleep": state = "chase"
		if self.health < 0:
			self.die()
			