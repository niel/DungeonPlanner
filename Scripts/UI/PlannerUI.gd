extends VBoxContainer

class UIContext:
  var currentScene: String = ""
  var recentScenes: Array[String] = []

signal tile_selected(tile: Tile)
signal new_scene()
signal save_current_scene(sceneName: String)
signal load_scene(sceneName: String)
signal quit_scene()

var context: UIContext
var resources: TileResources

@onready var tileSelectorUI = $%TileSelectorControl
@onready var setImportNode = $%SetSelectorControl
@onready var menuBar = $Top/MenuBar

@onready var fileButton = $Top/MenuBar/FileButton
@onready var saveAsDialog = $Top/MenuBar/FileButton/SaveAsDialogControl

func _ready():
  tileSelectorUI.tile_selected.connect(set_selected_tile)
  setImportNode.set_selected.connect(set_selected_set)
  fileButton.new_scene.connect(_on_file_new)
  fileButton.load_scene.connect(_on_file_load)
  fileButton.save_scene.connect(_on_file_save)
  fileButton.save_scene_as.connect(show_save_as_dialog)
  fileButton.quit_scene.connect(on_quit)
  saveAsDialog.saved_with_name.connect(_on_save_as)
  context = UIContext.new()
  if SceneContext.currentScene != null:
    context.currentScene = SceneContext.currentScene.sceneName

func set_tile_resources(newResources: TileResources):
  resources = newResources
  set_selected_set(resources.tileSets[0])
  setImportNode.set_selectable_sets(resources.tileSets)

func set_selected_tile(tile: Tile):
  tile_selected.emit(tile)

func set_selected_set(tileSet: DragonbiteTileSet):
  tileSelectorUI.set_selected_set(tileSet)

func set_save_names(names: Array[String]):
  context.recentScenes = names
  fileButton.set_saves(context.recentScenes)

func _on_file_new():
  context.currentScene = ""
  new_scene.emit()

func _on_file_load(sceneName: String):
  context.currentScene = sceneName
  load_scene.emit(sceneName)

func _on_file_save():
  if context.currentScene == "":
    show_save_as_dialog()
    return
  save_current_scene.emit(context.currentScene)

func show_save_as_dialog():
  saveAsDialog.visible = true

func _on_save_as(sceneName: String):
  context.currentScene = sceneName
  save_current_scene.emit(context.currentScene)
  fileButton.set_saves(context.recentScenes)

func on_quit():
  quit_scene.emit()

func on_viewport_resized(newSize: Vector2):
  setImportNode.on_viewport_resized(newSize)
  tileSelectorUI.on_viewport_resized(newSize)
