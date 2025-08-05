class_name SceneData
extends RefCounted

class SavedTile:
  const KEY_ID = "id"
  const KEY_ROTATION = "rotation"
  const KEY_X = "x"
  const KEY_Z = "z"

  var id = ""
  var occupied_spaces: Array = []
  var rotation: Vector3
  var x = 0
  var z = 0

const SIZE = Vector2(20, 20)
const KEY_SCENE_NAME = "sceneName"
const KEY_TILES = "tiles"

var scene_name = ""
var tiles = []

func to_json() -> String:
  var data: Dictionary = {}
  data[SceneData.KEY_SCENE_NAME] = scene_name
  data[SceneData.KEY_TILES] = []
  for tile in tiles:
    var tile_data: Dictionary = {}
    tile_data[SavedTile.KEY_ID] = tile.id
    tile_data[SavedTile.KEY_ROTATION] = tile.rotation - PlanningContext.DEFAULT_ROTATION
    tile_data[SavedTile.KEY_X] = tile.x
    tile_data[SavedTile.KEY_Z] = tile.z
    data[SceneData.KEY_TILES].append(tile_data)
  return JSON.stringify(data)

func from_json(json: String):
  tiles = []
  var data: Dictionary = JSON.parse_string(json)
  scene_name = data[SceneData.KEY_SCENE_NAME]
  for tile_data in data[SceneData.KEY_TILES]:
    var tile = SavedTile.new()
    tile.id = tile_data[SavedTile.KEY_ID]
    var rotation = split_on_any_of(tile_data[SavedTile.KEY_ROTATION], " ,()")
    tile.rotation = Vector3(
        float(rotation[0]),
        float(rotation[1]),
        float(rotation[2])
    ) + PlanningContext.DEFAULT_ROTATION
    tile.x = tile_data[SavedTile.KEY_X]
    tile.z = tile_data[SavedTile.KEY_Z]
    update_tile_offset(tile)
    tiles.append(tile)

func split_on_any_of(string: String, delimiters: String) -> Array:
  var tokens = []
  var current_token = ""
  for c in string:
    if delimiters.find(c) != -1:
      if current_token != "":
        tokens.append(current_token)
        current_token = ""
    else:
      current_token += c
  return tokens

func update_tile_offset(tile: SavedTile):
  var tile_data = SceneContext.get_tile_from_id(tile.id)
  if tile_data == null:
    print("[calculate_occupied_spaces] Tile with ID ", tile.id, " not found in context.")
    return
  var new_occupied_spaces = calculate_occupied_spaces(
      tile_data,
      Vector2(tile.x, tile.z),
      tile.rotation
  )
  tile.occupied_spaces.clear()
  tile.occupied_spaces.append_array(new_occupied_spaces)

func calculate_occupied_spaces(tile_data: Tile, position: Vector2, rotation: Vector3) -> Array:
  # Create base offsets based on tile size
  var x_size = tile_data.x_size
  var y_size = tile_data.y_size
  var x_end = x_size / 2
  var x_start = x_end - x_size + 1
  var y_end = y_size / 2
  var y_start = y_end - y_size + 1
  var occupied_space_offsets = []
  for x in range(x_start, x_end + 1):
    for y in range(y_start, y_end + 1):
      occupied_space_offsets.append(Vector2(x, y))
  # Rotate occupied spaces based on tile rotation
  while rotation.y < 0:
    rotation.y += 360
  while rotation.y >= 360:
    rotation.y -= 360
  if abs(rotation.y - 90) < 0.01:
    occupied_space_offsets = occupied_space_offsets.map(func(pos):
      return Vector2(pos.y, -pos.x))
  elif abs(rotation.y - 180) < 0.01:
    occupied_space_offsets = occupied_space_offsets.map(func(pos):
      return Vector2(-pos.x, -pos.y))
  elif abs(rotation.y - 270) < 0.01:
    occupied_space_offsets = occupied_space_offsets.map(func(pos):
      return Vector2(-pos.y, pos.x))
  # Combine offsets with position
  occupied_space_offsets = occupied_space_offsets.map(func(offset):
    return Vector2(position.x + offset.x, position.y + offset.y))
  return occupied_space_offsets

func has_tile_at(x: int, z: int) -> bool:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return true
  return false

func has_position_in_tile_occupying_space_excluding_self(
    position: Vector2,
    tile_origin: Vector2
) -> bool:
  for tile in tiles:
    if tile.x == tile_origin.x and tile.z == tile_origin.y:
      continue # Skip the tile at the given position
    for occupied_space in tile.occupied_spaces:
      if occupied_space.x == position.x and occupied_space.y == position.y:
        return true
  return false

func get_tile_at(x: int, z: int) -> SavedTile:
  for tile in tiles:
    if tile.x == x and tile.z == z:
      return tile
  return null

func get_origin_tile(position: Vector2) -> SavedTile:
  for tile in tiles:
    if tile.x == position.x and tile.z == position.y:
      return tile
    for occupied_space in tile.occupied_spaces:
      if occupied_space.x == position.x and occupied_space.y == position.y:
        return tile
  return null

func set_tile_at(x: int, z: int, tile_context: SceneContext.TileContext):
  if not does_tile_fit(tile_context.tile, Vector2(x, z), tile_context.rotation):
    return
  var saved_tile: SavedTile
  if (has_tile_at(x, z)):
    saved_tile = get_tile_at(x, z)
  else:
    saved_tile = SavedTile.new()
    saved_tile.x = x
    saved_tile.z = z
    tiles.append(saved_tile)
  saved_tile.id = tile_context.tile.id
  saved_tile.rotation = tile_context.rotation
  update_tile_offset(saved_tile)
  return

func remove_tile_at(x: int, z: int):
  for i in range(tiles.size()):
    if tiles[i].x == x and tiles[i].z == z:
      tiles.remove_at(i)
      return
  print("No tile found at position (", x, ", ", z, ") to remove.")

func does_tile_fit(tile: Tile, position: Vector2, rotation: Vector3) -> bool:
  var occupied_spaces = calculate_occupied_spaces(tile, position, rotation)
  for space in occupied_spaces:
    if has_position_in_tile_occupying_space_excluding_self(Vector2(space.x, space.y), position):
      return false
    if space.x < 0 or space.y < 0:
      return false
    if space.x >= SIZE.x or space.y >= SIZE.y:
      return false
  return true