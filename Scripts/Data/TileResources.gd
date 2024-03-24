class_name TileResources
extends RefCounted

const dragonBiteTileSetClass = preload("res://Scripts/Data/DragonbiteTileSet.gd")

var tileSets:Array = []
var selectedSetIdx = 0

func add_set_from_json(json:Dictionary):
  var newSet = dragonBiteTileSetClass.new()
  newSet.load_from_json(json)
  tileSets.append(newSet)

func get_selected_set() -> DragonbiteTileSet:
  return tileSets[selectedSetIdx]
