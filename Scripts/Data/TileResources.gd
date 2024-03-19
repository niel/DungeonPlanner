extends RefCounted

const dragonBiteTileSetClass = preload("res://Scripts/Data/DragonbiteTileSet.gd")

var tileSets:Array = []

func add_set_from_json(json:Array):
  var newSet = dragonBiteTileSetClass.new()
  newSet.load_from_json(json)
  tileSets.append(newSet)

func get_selected_set() -> DragonbiteTileSet:
  return tileSets[0]
