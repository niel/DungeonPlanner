extends MarginContainer

class UIContext:
  var currentScene: String = ""
  var recentScenes: Array[String] = []

signal tile_selected(tile: Tile)
signal new_scene()
signal save_current_scene(sceneName: String)
signal load_scene(sceneName: String)
signal quit_scene()

const unsavedChangesDontSaveAction: StringName = "dont_save"

var context: UIContext
var resources: TileResources
var unsavedChanges: bool = false

@onready var tileSelectorUI = $%TileSelectorControl
@onready var setImportNode = $%SetSelectorControl
@onready var menuBar = $%MenuBar
@onready var fileButton = $%FileButton
@onready var saveAsDialog = $%SaveAsDialogControl
@onready var unsavedChangesDialog = $%UnsavedChangesDialog
@onready var unsavedChangesSaveAsDialog = $%UnsavedChangesSaveAsDialog

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
  unsavedChanges = false
  save_current_scene.emit(context.currentScene)

func show_save_as_dialog():
  saveAsDialog.visible = true

func _on_save_as(sceneName: String):
  context.currentScene = sceneName
  unsavedChanges = false
  save_current_scene.emit(context.currentScene)
  fileButton.set_saves(context.recentScenes)

func on_quit():
  if unsavedChanges:
    unsavedChangesDialog.visible = true
  else:
    quit_scene.emit()

func on_viewport_resized(newSize: Vector2):
  setImportNode.on_viewport_resized(newSize)
  tileSelectorUI.on_viewport_resized(newSize)

func on_board_tile_placed() -> void:
  unsavedChanges = true

func unsaved_changes_save():
  if SceneContext.currentScene.sceneName == "":
    unsavedChangesSaveAsDialog.visible = true
  else:
    save_current_scene.emit(SceneContext.currentScene.sceneName)
    quit_scene.emit()

func unsaved_changes_custom(action: StringName):
  if unsavedChangesDontSaveAction == action:
    quit_scene.emit()
  else:
    print("Unknown unsaved changes action: ", action)

func on_unsaved_changes_save_as_dialog_saved(scene_name: String) -> void:
  SceneContext.currentScene.sceneName = scene_name
  save_current_scene.emit(SceneContext.currentScene.sceneName)
  quit_scene.emit()
