extends Node

var planningContextClass = preload("res://Scripts/PlanningContext.gd")

var planning_context = planningContextClass.new()
@onready var board = $Board
@onready var plannerUI = $CanvasLayer/PlannerUI
@onready var inputListener = $InputListener

func _ready():
  planning_context.initialize()
  inputListener.connect_context(planning_context)
  board.connect_to_context(planning_context)
  board.create_board()
  plannerUI.set_selected_set(planning_context.tile_resources.get_selected_set())
  plannerUI.tile_selected.connect(planning_context.update_selected_tile)
