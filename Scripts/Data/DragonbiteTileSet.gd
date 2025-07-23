class_name DragonbiteTileSet
extends RefCounted

const meshesPath = "user://Meshes/"
const keyName = "name"
const keyTiles = "tiles"
const keyTileImagePath = "imagePath"
const keyTileName = "name"
const keyTileId = "id"
const keyTileResPath = "resPath"

var tiles:Array = []
var name:String = ""

func load_from_json(json: Dictionary):
  var statusCount: Array = [0, 0, 0, 0]
  var startTime = Time.get_ticks_msec()
  for tileJson in json[keyTiles]:
    var tile := Tile.new()
    var status = tile.load_imported_tile(tileJson)
    statusCount[status] += 1
    tiles.append(tile)
  name = json[keyName]
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

func import_tile(stlFilePath: String) -> Tile:
  var newTile := Tile.new()
  var destFile = stlFilePath.get_file().get_slice(".", 0)
  var destPath = meshesPath + name + "/" + destFile + ".res"
  var status = newTile.create_tile(stlFilePath, destPath)
  if status == Tile.TileStatus.CREATED or status == Tile.TileStatus.CACHED:
    tiles.append(newTile)
    return newTile
  else:
    print("Failed to import tile from ", stlFilePath)
    return null

func get_tile(index: int) -> Tile:
  if index < 0 or index >= tiles.size():
    print("Index out of bounds: ", index, " for tileset ", name)
    return null
  return tiles[index]

func get_size() -> int:
  return tiles.size()
