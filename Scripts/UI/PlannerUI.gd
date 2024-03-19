extends Node

signal tile_selected(tile: Tile)

@onready var selectorUI = $TileSelectorContainer/TileSelectorControl

func _ready():
  selectorUI.tile_selected.connect(set_selected_tile)

func set_selected_set(tileSet: DragonbiteTileSet):
  selectorUI.set_selected_set(tileSet)

func set_selected_tile(tile: Tile):
  tile_selected.emit(tile)


func _on_previous_pressed():
  selectorUI.go_to_previous_page()


func _on_next_pressed():
  selectorUI.go_to_next_page()
