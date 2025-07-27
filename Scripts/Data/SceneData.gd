class_name SceneData
extends RefCounted

class SavedTile:
  const key_id = "id"
  const key_rotation = "rotation"
  const key_x = "x"
  const key_z = "z"

  var id = ""
  var occupiedSpaces: Array = []
  var rotation: Vector3
  var x = 0
  var z = 0

const key_sceneName = "sceneName"
const key_tiles = "tiles"

var sceneName = ""
var tiles = []

func toJson() -> String:
  var data: Dictionary = {}
  data[SceneData.key_sceneName] = sceneName
  data[SceneData.key_tiles] = []
  for tile in tiles:
    var tileData: Dictionary = {}
    tileData[SavedTile.key_id] = tile.id
    tileData[SavedTile.key_rotation] = tile.rotation - PlanningContext.defaultRotation
    tileData[SavedTile.key_x] = tile.x
    tileData[SavedTile.key_z] = tile.z
    data[SceneData.key_tiles].append(tileData)
  return JSON.stringify(data)

func fromJson(json: String):
  tiles = []
  var data: Dictionary = JSON.parse_string(json)
  sceneName = data[SceneData.key_sceneName]
  for tileData in data[SceneData.key_tiles]:
    var tile = SavedTile.new()
    tile.id = tileData[SavedTile.key_id]
    var rotation = splitOnAnyOf(tileData[SavedTile.key_rotation], " ,()")
    tile.rotation = Vector3(float(rotation[0]), float(rotation[1]), float(rotation[2])) + PlanningContext.defaultRotation
    tile.x = tileData[SavedTile.key_x]
    tile.z = tileData[SavedTile.key_z]
    calculateOccupiedSpaces(tile)
    tiles.append(tile)

func splitOnAnyOf(string: String, delimiters: String) -> Array:
  var tokens = []
  var currentToken = ""
  for c in string:
    if delimiters.find(c) != -1:
      if currentToken != "":
        tokens.append(currentToken)
        currentToken = ""
    else:
      currentToken += c
  return tokens

func calculateOccupiedSpaces(tile: SavedTile):
  var tileData = SceneContext.get_tile_from_id(tile.id)
  if tileData == null:
    print("[calculateOccupiedSpaces] Tile with ID ", tile.id, " not found in context.")
    return
  var xSize = tileData.x_size
  var ySize = tileData.y_size
  tile.occupiedSpaces.clear()
  var xEnd = xSize / 2
  var xStart = xEnd - xSize + 1
  var yEnd = ySize / 2
  var yStart = yEnd - ySize + 1
  for x in range(xStart, xEnd + 1):
    for y in range(yStart, yEnd + 1):
      tile.occupiedSpaces.append(Vector2(tile.x + x, tile.z + y))

func hasTileAt(x: int, z: int) -> bool:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return true
  return false

func getTileAt(x: int, z: int) -> SavedTile:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return tile
  return null

func setTileAt(x: int, z: int, tileContext: SceneContext.TileContext):
  var savedTile: SavedTile
  if (hasTileAt(x, z)):
    savedTile = getTileAt(x, z)
  else:
    savedTile = SavedTile.new()
    savedTile.x = x
    savedTile.z = z
    tiles.append(savedTile)
  savedTile.id = tileContext.tile.id
  savedTile.rotation = tileContext.rotation
  calculateOccupiedSpaces(savedTile)
  return
