class_name TileResources
extends RefCounted

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

func remove_set(set_name: String):
  for i in range(tile_sets.size()):
    if tile_sets[i].name == set_name:
      tile_sets[i].delete_tiles()
      tile_sets.remove_at(i)
      return
