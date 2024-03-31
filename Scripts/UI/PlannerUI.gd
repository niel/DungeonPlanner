extends Node

signal tile_selected(tile: Tile)
signal save_current_scene()
signal load_scene()

var resources: TileResources

@onready var tileSelectorUI = $TileSelectorContainer/TileSelectorControl
@onready var setSelectorUI = $LeftColumn/SetSelectorControl

func _ready():
  tileSelectorUI.tile_selected.connect(set_selected_tile)
  setSelectorUI.set_selected.connect(set_selected_set)

func set_tile_resources(newResources: TileResources):
  resources = newResources
  set_selected_set(resources.tileSets[1])
  setSelectorUI.set_selectable_sets(resources.tileSets)

func set_selected_tile(tile: Tile):
  tile_selected.emit(tile)

func set_selected_set(tileSet: DragonbiteTileSet):
  tileSelectorUI.set_selected_set(tileSet)

func _on_previous_pressed():
  tileSelectorUI.go_to_previous_page()

func _on_next_pressed():
  tileSelectorUI.go_to_next_page()


func _on_save_pressed():
  save_current_scene.emit()


func _on_load_pressed():
  load_scene.emit()
