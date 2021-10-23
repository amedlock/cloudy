extends Node2D


const Util = preload("util.gd")

var dungeon_mode
var map_mode


func _ready():
	map_mode = $MapMode
	dungeon_mode = $DungeonMode
	self.remove_child( dungeon_mode )
	self.remove_child( map_mode )
	$Title.connect("start", self, "start_game" )
	$Title.show()
	OS.set_window_maximized(true)


func start_game( ):
	self.remove_child( $Title )
	self.add_child( map_mode )

func enter_dungeon( kind ):
	var p = map_mode.player
	remove_child( map_mode )
	add_child( dungeon_mode )
	dungeon_mode.start_dungeon(kind, p)
	Input.set_mouse_mode( Input.MOUSE_MODE_HIDDEN )
	
	
func exit_dungeon(p):
	self.add_child( map_mode )
	self.remove_child( dungeon_mode )
	map_mode.exit_dungeon(p)
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	

func won_game():
	self.add_child( map_mode )
	self.remove_child( dungeon_mode )
	map_mode.game_state = "won"
	
func lost_game():
	self.add_child( map_mode )
	self.remove_child( dungeon_mode )
	map_mode.game_state = "died"
