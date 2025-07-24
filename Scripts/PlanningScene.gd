extends Node

const UI_SCALE = 0.00054

var planningContext
var saveManager: SaveManager = SaveManager.new()
var viewport
@onready var board = $Board
@onready var uiCanvas = $CanvasLayer
@onready var plannerUI = $CanvasLayer/PlannerUI
@onready var inputListener = $InputListener

func _ready():
  planningContext = PlanningSceneContext.get_instance(self)
  inputListener.connect_context(planningContext)
  board.connect_to_context(planningContext)
  board.create_board()
  board.load_scene(planningContext.currentScene)
  plannerUI.set_tile_resources(planningContext.tileResources)
  plannerUI.tile_selected.connect(planningContext.update_selected_tile)
  plannerUI.new_scene.connect(self.new_scene) 
  plannerUI.save_current_scene.connect(self.save_scene)
  plannerUI.load_scene.connect(self.load_scene)
  print(saveManager.sceneNames)
  plannerUI.set_save_names(saveManager.sceneNames)
  viewport = get_viewport()
  viewport.size_changed.connect(resize_ui)
  resize_ui()

func resize_ui():
  uiCanvas.transform.x = Vector2(viewport.size[1] * UI_SCALE, 0)
  uiCanvas.transform.y = Vector2(0, viewport.size[1] * UI_SCALE)

func new_scene():
  var newScene = SceneData.new()
  planningContext.currentScene = newScene
  board.load_scene(newScene)

func save_scene(scene_name: String):
  planningContext.currentScene.sceneName = scene_name
  var sceneData = planningContext.currentScene
  saveManager.save_scene_to_user(sceneData)

func load_scene(scene_name: String):
  var sceneData = saveManager.load_scene_from_user(scene_name)
  planningContext.set_current_scene(sceneData)
  board.load_scene(sceneData)
