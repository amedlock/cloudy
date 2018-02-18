extends Node2D

var player
var dungeon
var grid

func _ready():
	dungeon = get_parent()
	grid = dungeon.get_node("Tiles")
	player = dungeon.get_node("Player")


func search( e, dist ):
	var cell = grid.pos_to_index( e.position )
	if dist < 100 or cell==player.cell:
		e.state = "attack"
		return
	e.path.clear()
	for p in dungeon.calc_nav_path( cell, player.cell ):
		e.path.append( p )
	e.path.remove(0)
	if e.path.empty():
		e.state = "attack" # could not find path, dont keep trying
	else:
		e.state = "chase"
	
func move_towards( e, pt, delta ):
	var d = (pt - e.position)
	e.get_node("Sprite").flip_h = d.x < 0
	if d.length() < 1:
		return true
	var d2 = e.move_and_slide( d.normalized() * e.speed )
	
func move_along_path( e, dist, delta ):
	var next = e.path[0]
	var next_dist = e.position.distance_to( next )
	if next_dist <= 4:
		e.path.remove(0)
	else:
		move_towards( e, next, delta )	
	

func chase( e, dist, delta ):
	var cell = grid.pos_to_index( e.position )
	if cell==player.cell:
		e.state ="attack"
	elif e.path.empty():
		e.state = "search"
	else:
		move_along_path( e, dist, delta )


func attack( e, delta ):
	var cell = grid.pos_to_index( e.position )
	if cell != player.cell:
		e.state = "search"
	else:
		move_towards( e, player.position, delta )


var blood = preload("res://game/enemy/blood.tscn")

func add_blood( e ):
	var b = blood.instance()
	b.rotation_degrees = randi() % 359;
	b.position = e.position 
	self.add_child( b )


func heard_shot():
	var grid = get_parent().get_node("Tiles")
	var c = grid.pos_to_coord( player.position )
	for c2 in grid.nearby_cells( c.x, c.y ):
		for e in self.all_enemies():
			if c2.contains_point( e.position ):
				e.awaken()
	

const Monster_Attack_Distance = 50


func all_enemies():
	return get_tree().get_nodes_in_group("enemy")

func _process(delta):
	if player.alive==false:
		return
	for e in all_enemies():
		if e.state in ["wait", "sleep"]: 
			continue
		var dist = e.position.distance_to( player.position )
		if dist < Monster_Attack_Distance:
			player.hurt( e , delta )
		if e.state=="alert" and dist < 200:
			e.state = "search"
		if e.state=="search":
			search( e, dist )
		elif e.state=="chase":
			chase( e, dist, delta )
		elif e.state=="attack":
			attack( e, delta )
