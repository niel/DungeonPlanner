extends Node

class UIContext:
  var currentScene: String = ""
  var recentScenes: Array[String] = []

signal tile_selected(tile: Tile)
signal new_scene()
signal save_current_scene()
signal load_scene(sceneName: String)

var context: UIContext = UIContext.new()
var resources: TileResources
var saveNames: Array[String] = ["scene1", "scene2", "scene3"]

@onready var tileSelectorUI = $Left/HSplitContainer/TileSelectorContainer/TileSelectorControl
@onready var setSelectorUI = $Left/HSplitContainer/LeftColumn/SetSelectorControl
@onready var menuBar = $Top/MenuBar

func _ready():
  tileSelectorUI.tile_selected.connect(set_selected_tile)
  setSelectorUI.set_selected.connect(set_selected_set)
  var fileButton = menuBar.get_node(NodePath("./FileButton"))
  fileButton.new_scene.connect(self._on_file_new)
  fileButton.load_scene.connect(self._on_file_load)
  fileButton.save_scene.connect(self._on_file_save)

func set_tile_resources(newResources: TileResources):
  resources = newResources
  set_selected_set(resources.tileSets[1])
  setSelectorUI.set_selectable_sets(resources.tileSets)

func set_selected_tile(tile: Tile):
  tile_selected.emit(tile)

func set_selected_set(tileSet: DragonbiteTileSet):
  tileSelectorUI.set_selected_set(tileSet)

func set_save_names(names: Array[String]):
  saveNames = names
  menuBar.get_node(NodePath("./FileButton")).set_saves(saveNames)

func _on_previous_pressed():
  tileSelectorUI.go_to_previous_page()

func _on_next_pressed():
  tileSelectorUI.go_to_next_page()

func _on_file_new():
  context.currentScene = ""
  new_scene.emit()

func _on_file_load(sceneName: String):
  context.currentScene = sceneName
  load_scene.emit(sceneName)

func _on_file_save():
  if context.currentScene == "":
    print("No scene to save")
    return
  save_current_scene.emit()
