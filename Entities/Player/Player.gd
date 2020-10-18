extends Node2D

class_name Player

var move_path: Array = [] setget set_move_path

onready var path: Line2D = $"../PathVisual"
onready var grid_manager: GridManager = get_parent()
onready var cell_size: Vector2 = grid_manager.cell_size

signal moved

func _ready():
	GameManager.player = self

func _process(delta):
	var moveTo := position
	
	if Input.is_action_just_pressed("left"):
		moveTo.x -= cell_size.x
	elif Input.is_action_just_pressed("right"):
		moveTo.x += cell_size.x
	elif Input.is_action_just_pressed("up"):
		moveTo.y -= cell_size.y
	elif Input.is_action_just_pressed("down"):
		moveTo.y += cell_size.y
	elif Input.is_action_just_pressed("touch"):
		var mouse_pos: Vector2 = $Camera2D.get_global_mouse_position() - (cell_size / 2)
		var points = grid_manager.get_move_path(position, mouse_pos.snapped(cell_size))
		
		if points.size() > 1:
			self.move_path = points
			move_path.pop_front()
			
			$SleepTimer.start()

	if moveTo != position and grid_manager.can_move_to(moveTo):
		self.move_path = []
		move(moveTo)
		
func move(pos):
	#grid_manager.free_cell(position)
	position = pos
	#grid_manager.reserve_cell(position)
	emit_signal("moved")

func set_move_path(value):
	move_path = value
	path.points = value

func _on_SleepTimer_timeout():
	if move_path.size() > 0:
		var moveTo = move_path.pop_front()
		
		if moveTo != position and grid_manager.can_move_to(moveTo):
			move(moveTo)
			$SleepTimer.start()
