extends Area2D

const Util = preload("../util.gd")
const Step_Amount = 20;
const speed = 150


var enemies
var dungeon

var my_cell
var target_cell
var fr = 0
var travel = 0

signal died

func _ready():
	self.connect("body_entered", self, "hit" )
	enemies = get_parent()
	dungeon = enemies.get_parent()
	$Timer.wait_time = 0.5
	$Timer.one_shot = false
	$Audio.stream = load("res://assets/bat.wav")
	$Timer.connect("timeout", self, "play_sound")
	$Timer.start()


func hit(other):
	if other.kind=="arrow":
		$Audio.stop()
		other.queue_free()
		self.emit_signal("died", self)

	
func play_sound():
	if not $Audio.is_playing():
		$Audio.play()



func move_to_target(delta):
	var d = target_cell.center() - position
	if d.length() < 2:
		self.position = target_cell.center()
		my_cell = target_cell
		target_cell = null
	else:
		var amt = speed * delta
		self.translate( d.normalized() * amt )
		travel += amt
		while travel >= Step_Amount:
			fr = (fr+1)
			travel -= Step_Amount
		fr = fr % 4


func _process(delta):
	if my_cell==null:
		my_cell = dungeon.tiles.at_pos( self.position )
	if target_cell!=null:
		move_to_target( delta )
	else:
		var near = dungeon.connected_tiles( my_cell.coord.x, my_cell.coord.y )
		target_cell = Util.choice( near )
	$Sprite.region_rect.position.x = fr * 32
