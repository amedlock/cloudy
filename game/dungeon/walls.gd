extends Node2D


func hit(other):
	if other.kind=="arrow":
		other.queue_free()
