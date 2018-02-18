extends KinematicBody2D

var kind = "dragon"

var health = 4
var speed = 235
var damage = 60


var state = "sleep"
var path = []


var warn_sound = preload("res://assets/dragon_warn.wav")
var roar_sound = preload("res://assets/dragon.wav")

signal died 

func _ready():
	$Timer.wait_time = 2
	$Timer.one_shot = true
	$Audio.stream = warn_sound
	$Timer.connect( "timeout", self, "play_sound" )


func play_sound():
	$Audio.play()


func warn():
	if state!="sleep" or $Audio.playing: 
		return 
	if $Timer.is_stopped():
		$Timer.start()

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

func die():
	self.emit_signal("died" , self )

func wait():
	self.state = "wait"
	$Timer.stop()
	$Audio.stop()

func alert():
	state ="alert"
	$Timer.stop()
	path =[]

func sleep():
	self.path =[]
	$Audio.stop()
	$Timer.stop()
	$Timer.wait_time = 2
	$Timer.one_shot = true
	$Audio.stream = warn_sound


func hit(other):
	if other.kind=="arrow":
		self.health-= 1
		other.queue_free()
		get_parent().add_blood( self )
		if state=="sleep": state = "chase"
		if self.health < 0:
			self.die()

