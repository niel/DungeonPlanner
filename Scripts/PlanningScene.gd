extends Node

var saveManager: SaveManager = SaveManager.new()
var viewport
@onready var board = $Board
@onready var plannerUI = $%PlannerUI
@onready var inputListener = $InputListener

func _ready():
  board.create_board()
  board.load_scene(SceneContext.currentScene)
  plannerUI.set_tile_resources(SceneContext.tileResources)
  plannerUI.tile_selected.connect(SceneContext.update_selected_tile)
  plannerUI.new_scene.connect(self.new_scene)
  plannerUI.save_current_scene.connect(self.save_scene)
  plannerUI.load_scene.connect(self.load_scene)
  plannerUI.set_save_names(saveManager.sceneNames)
  viewport = get_viewport()
  viewport.size_changed.connect(on_viewport_resized)

func new_scene():
  var newScene = SceneData.new()
  SceneContext.currentScene = newScene
  board.load_scene(newScene)

func save_scene(scene_name: String):
  SceneContext.currentScene.sceneName = scene_name
  var sceneData = SceneContext.currentScene
  saveManager.save_scene_to_user(sceneData)

func load_scene(scene_name: String):
  var sceneData = saveManager.load_scene_from_user(scene_name)
  SceneContext.set_current_scene(sceneData)
  board.load_scene(sceneData)

func on_viewport_resized():
  plannerUI.on_viewport_resized(viewport.size)