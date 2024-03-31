extends Node

const UI_SCALE = 0.00054

var planningContextClass = preload ("res://Scripts/PlanningContext.gd")

var planning_context = planningContextClass.new()
var viewport
@onready var board = $Board
@onready var uiCanvas = $CanvasLayer
@onready var plannerUI = $CanvasLayer/PlannerUI
@onready var inputListener = $InputListener

func _ready():
  planning_context.initialize()
  inputListener.connect_context(planning_context)
  board.connect_to_context(planning_context)
  board.create_board()
  plannerUI.set_tile_resources(planning_context.tileResources)
  plannerUI.tile_selected.connect(planning_context.update_selected_tile)
  plannerUI.save_current_scene.connect(planning_context.save_current_scene)
  plannerUI.load_scene.connect(planning_context.load_scene)
  planning_context.scene_loaded.connect(board.load_scene)
  viewport = get_viewport()
  viewport.size_changed.connect(resize_ui)

func resize_ui():
  uiCanvas.transform.x = Vector2(viewport.size[1] * UI_SCALE, 0)
  uiCanvas.transform.y = Vector2(0, viewport.size[1] * UI_SCALE)
