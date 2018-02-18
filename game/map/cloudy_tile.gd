extends Node2D

var sound = true
var fr = 0

func _ready():
	$Timer.connect("timeout", self, "anim_tick" )
	$Audio.bus = "Master"

func anim_tick():
	fr = (fr + 1) % 3
	$Clouds.region_rect.position.x = 32 * fr
	if fr==2 and sound:
		$Audio.play()



	


