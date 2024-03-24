class_name DragonbiteTileSet
extends RefCounted

const tileClass = preload("res://Scripts/Data/Tile.gd")

var tiles:Array = []
var name:String = ""

func load_from_json(json:Dictionary):
  for tileJson in json["tiles"]:
    var tile: Tile = tileClass.new()
    tile.create_tile_from_json(tileJson)
    tiles.append(tile)
  name = json["name"]

func get_size() -> int:
  return tiles.size()
