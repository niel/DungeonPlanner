class_name DragonbiteTileSet
extends RefCounted

const meshesPath = "user://Meshes/"

var tiles:Array = []
var name:String = ""

func load_from_json(json: Dictionary):
  var statusCount: Array = [0, 0, 0, 0]
  var startTime = Time.get_ticks_msec()
  for tileJson in json["tiles"]:
    var tile := Tile.new()
    var status = tile.load_imported_tile(tileJson)
    statusCount[status] += 1
    tiles.append(tile)
  name = json["name"]
  var endTime = Time.get_ticks_msec()
  print("Loaded tileset " + name + " in " + str(endTime - startTime) + "ms")
  print("Cached: ", statusCount[0], " Created: ", statusCount[1], " Not found: ", statusCount[2])

func import_set(setName: String, stlFilePaths: PackedStringArray):
  name = setName
  var startTime = Time.get_ticks_msec()
  for path in stlFilePaths:
    var newTile := Tile.new()
    var destFile = path.get_file().get_slice(".", 0)
    var destPath = meshesPath + name + "/" + destFile + ".res"
    newTile.create_tile(path, destPath)
  var endTime = Time.get_ticks_msec()
  print("Imported tileset " + name + " in " + str(endTime - startTime) + "ms")

func get_size() -> int:
  return tiles.size()
