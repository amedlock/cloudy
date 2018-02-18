extends KinematicBody2D

var kind 

var shooter

var speed = 450

func _physics_process(delta):
	var ldir = Vector2(1,0).rotated( self.rotation )
	var other = self.move_and_collide( ldir * speed * delta )
	if not other:
		return
	var obj = other.collider
	if obj!=shooter:
		obj.hit(self)

func hit(other):
	pass

