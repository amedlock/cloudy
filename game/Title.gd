extends Sprite

signal start;

func _input(event):
	if not (event is InputEventKey):
		return
	if event.is_pressed():
		self.emit_signal("start")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
