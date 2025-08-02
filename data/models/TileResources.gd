class_name TileResources
extends RefCounted

var tileSets: Array = []
var selectedSetIdx = 0

func add_imported_set(json: Dictionary):
  var newSet := DragonbiteTileSet.new()
  newSet.load_from_json(json)
  tileSets.append(newSet)

func add_set(new_set: DragonbiteTileSet):
  tileSets.append(new_set)

func import_set(setName: String, stlFilePaths: Array):
  var newSet := DragonbiteTileSet.new()
  newSet.import_set(setName, stlFilePaths)
  tileSets.append(newSet)

func get_selected_set() -> DragonbiteTileSet:
  return tileSets[selectedSetIdx]

func remove_set(setName: String):
  for i in range(tileSets.size()):
    if tileSets[i].name == setName:
      tileSets[i].delete_tiles()
      tileSets.remove_at(i)
      return
