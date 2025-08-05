extends VBoxContainer

signal copy_tile(selected: Tile)

const NAME_TEMPLATE: String = "Name: %s"
const SET_TEMPLATE: String = "Set: %s"

var selected_tile: Tile

@onready var tile_name_label = $%Name
@onready var tile_set_label = $%Set

func set_state(tileset_name: String, tile: Tile):
  selected_tile = tile
  tile_name_label.text = NAME_TEMPLATE % selected_tile.name
  tile_set_label.text = SET_TEMPLATE % tileset_name

func forward_copy_tile():
  if selected_tile == null:
    return
  copy_tile.emit(selected_tile)
