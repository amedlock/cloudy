extends KinematicBody2D

var kind = "player"

var touching = null;
var inventory = []

var alive = true 
var health = 100
var arrows = 20
var lives = 3
var Speed = 200


const Reload_Time = 0.5

var cell = 0
onready var dungeon = get_parent()


var reload = 0

onready var cross = $cross
onready var arrow_prefab = preload("res://game/dungeon/arrow.tscn")
onready var camera = get_node("Camera")

signal died
signal fired


func reset(sx ,sy ):
	alive = true
	$Sprite.show()	
	health = 100
	self.position = Vector2( sx, sy )
	up = false
	down = false
	left = false
	right = false


func die():
	alive = false
	$Sprite.hide()
	health = 0
	self.emit_signal("died")


var move = Vector2(0,0)



var movement_map = {
	"left" : Vector2(-1,0),
	"up_left" : Vector2(-1,-1),
	"up" : Vector2(0,-1),
	"up_right" : Vector2(1,-1),
	"right" : Vector2(1,0),
	"down_right" : Vector2(1,1),
	"down" : Vector2(0,1),
	"down_left" : Vector2(-1,1)
	}
	
var up = false
var down = false
var right = false
var left = false	

func _input(event):
	if not alive: return
	if event.is_action_pressed("fire_arrow"):
		self.fire()
	elif event is InputEventKey:
		if event.is_action("up"):
			up = event.pressed
		elif event.is_action("down"):
			down = event.pressed
		elif event.is_action("left"):
			left = event.pressed
		elif event.is_action("right"):
			right = event.pressed
		elif event.is_action("use") and self.touching!=null:
			self.activate( self.touching )


func activate( item ):
	if item.kind=="ladder":
		get_parent().exit_dungeon()
	if item.kind=="quiver":
		self.arrows += 10
	else:
		self.inventory.append( item.kind )
	item.get_parent().remove_child( item )
	item.queue_free()
	if "crown1" in self.inventory:
		if "crown2" in self.inventory:
			get_parent().won_game()
	


func fire():
	if arrows<1 or reload>0:
		return
	arrows -= 1
	reload = Reload_Time
	get_parent().play_sound( "res://assets/fire.wav", "Effects" )
	self.emit_signal( "fired" )
	var diff = get_global_mouse_position() - self.global_position
	var ang = diff.angle()
	var arrow = arrow_prefab.instance()
	arrow.kind = "arrow"
	arrow.shooter = self
	get_parent().add_child( arrow )
	var off = Vector2(16,0).rotated( ang )
	arrow.position= self.position + off
	arrow.rotation = ang

	
func hurt(e, delta):
	self.health -= e.damage * delta


var frame = 0
var travel = 0
var step_size = 15
var walk_frames = [ Vector2(0,4), Vector2(1,4), Vector2(2,4), Vector2(3,4) ]



func update_anim():
	frame = frame % walk_frames.size()
	$Sprite.region_rect.position = walk_frames[frame] * 32



onready var health_ui= $Camera/UI/Health
onready var arrows_ui = $Camera/UI/Arrows

func _process(delta):
	if reload>0: reload = max( reload- delta , 0 )
	
	cross.position = get_local_mouse_position()
	get_parent().reveal()
	health_ui.text = "Health:" + str(int(health))
	arrows_ui.text = "Arrows:" + str(arrows)
	if alive and self.health < 0:
		self.die()

func _physics_process(delta):
	if not alive: return
	if up: move.y = -1 
	elif down: move.y =1
	else: move.y = 0
	
	if left: 
		move.x = -1 
		$Sprite.flip_h = true
	elif right: 
		move.x =1
		$Sprite.flip_h = false
	else: 
		move.x = 0
	
	if move.x==0 and move.y==0:
		frame = 0
		travel = 0
	else:
		var prev = self.position
		var d = move_and_collide( move * Speed * delta ) 
		travel += ( prev - self.position ).length()
		cell = dungeon.get_node("Tiles").pos_to_index( position )
		while travel > step_size:
			travel -= step_size
			frame+= 1
		if d and not ( d.collider is StaticBody2D ):
			d.collider.hit( self )
	update_anim()
	

