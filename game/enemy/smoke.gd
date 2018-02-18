extends Sprite

var elapsed = 0

export(float) var time_per_frame = 0.4;
export(float) var total = 2.5;

signal done

func _process(delta):
	elapsed += delta
	if elapsed > total:
		self.emit_signal("done")
		self.queue_free()
	var fr = int( elapsed / time_per_frame ) % 3
	self.region_rect.position.x = 128 + ( fr * 32 )
	self.position.y -= delta * 4
	

