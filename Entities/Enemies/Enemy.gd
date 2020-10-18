extends Node2D

class_name Enemy

onready var grid_manager: GridManager = get_parent()

signal moved

func _ready():
	grid_manager.connect("grid_refreshed", self, "sync_with_grid")

func move_towards_player():
	grid_manager.free_cell(position)
	var move_path = grid_manager.get_move_path(position, GameManager.player.position)
	
	if move_path.size() > 2:
		move_path.pop_front()
		var moveTo = move_path.pop_front()
		
		emit_signal("moved", position, moveTo)
		position = moveTo
			
	grid_manager.reserve_cell(position)

func sync_with_grid():
	grid_manager.reserve_cell(position)
