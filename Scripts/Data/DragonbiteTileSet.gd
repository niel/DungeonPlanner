class_name DragonbiteTileSet
extends RefCounted

const tileClass = preload("res://Scripts/Data/Tile.gd")

var tiles:Array = []
var name:String = ""
var statusCount:Array = [0, 0, 0]

func load_from_json(json:Dictionary):
  var startTime = Time.get_ticks_msec()
  for tileJson in json["tiles"]:
    var tile: Tile = tileClass.new()
    var status = tile.create_tile_from_json(tileJson)
    statusCount[status] += 1
    tiles.append(tile)
  name = json["name"]
  var endTime = Time.get_ticks_msec()
  print("Loaded tileset " + name + " in " + str(endTime - startTime) + "ms")
  print("Cached: ", statusCount[0], " Created: ", statusCount[1], " Not found: ", statusCount[2])

func get_size() -> int:
  return tiles.size()
