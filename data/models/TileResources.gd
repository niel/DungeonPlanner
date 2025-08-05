class_name TileResources
extends RefCounted

const KEY_SET = "set"
const KEY_TILE = "tile"

var tile_sets: Array = []
var selected_set_idx = 0

func add_imported_set(json: Dictionary):
  var new_set := DragonbiteTileSet.new()
  new_set.load_from_json(json)
  tile_sets.append(new_set)

func add_set(new_set: DragonbiteTileSet):
  tile_sets.append(new_set)

func import_set(set_name: String, stl_file_paths: Array):
  var new_set := DragonbiteTileSet.new()
  new_set.import_set(set_name, stl_file_paths)
  tile_sets.append(new_set)

func get_selected_set() -> DragonbiteTileSet:
  return tile_sets[selected_set_idx]

func get_set_and_tile_data(tile_id: String) -> Dictionary:
  for tile_set in tile_sets:
    for tile in tile_set.tiles:
      if tile.id == tile_id:
        return {KEY_SET: tile_set, KEY_TILE: tile}
  return {KEY_SET: null, KEY_TILE: null}

func remove_set(set_name: String):
  for i in range(tile_sets.size()):
    if tile_sets[i].name == set_name:
      tile_sets[i].delete_tiles()
      tile_sets.remove_at(i)
      return
