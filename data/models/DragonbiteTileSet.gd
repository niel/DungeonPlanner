class_name DragonbiteTileSet
extends RefCounted

const MESHES_PATH = "user://Meshes/"
const KEY_NAME = "name"
const KEY_TILES = "tiles"
const KEY_TILE_IMAGE_PATH = "imagePath"
const KEY_TILE_NAME = "name"
const KEY_TILE_ID = "id"
const KEY_TILE_RES_PATH = "resPath"
const KEY_TILE_X_SIZE = "xSize"
const KEY_TILE_Y_SIZE = "ySize"

var tiles: Array = []
var name: String = ""

func load_from_json(json: Dictionary):
  var status_count: Array = [0, 0, 0, 0]
  var start_time = Time.get_ticks_msec()
  for tile_json in json[KEY_TILES]:
    var tile := Tile.new()
    var status = tile.load_imported_tile(tile_json)
    status_count[status] += 1
    tiles.append(tile)
  name = json[KEY_NAME]
  var end_time = Time.get_ticks_msec()
  print("Loaded tileset " + name + " in " + str(end_time - start_time) + "ms")
  print("Cached: ", status_count[0], " Created: ", status_count[1], " Not found: ", status_count[2])

func import_set(set_name: String, stl_file_paths: PackedStringArray):
  name = set_name
  var start_time = Time.get_ticks_msec()
  for path in stl_file_paths:
    var new_tile := Tile.new()
    var dest_file = path.get_file().get_slice(".", 0)
    var dest_path = MESHES_PATH + name + "/" + dest_file + ".res"
    new_tile.create_tile(path, dest_path)
  var end_time = Time.get_ticks_msec()
  print("Imported tileset " + name + " in " + str(end_time - start_time) + "ms")

func import_tile(stl_file_path: String) -> Tile:
  var new_tile := Tile.new()
  var dest_file = stl_file_path.get_file().get_slice(".", 0)
  var dest_path = MESHES_PATH + name + "/" + dest_file + ".res"
  var status = new_tile.create_tile(stl_file_path, dest_path)
  if status == Tile.TileStatus.CREATED or status == Tile.TileStatus.CACHED:
    tiles.append(new_tile)
    return new_tile
  print("Failed to import tile from ", stl_file_path)
  return null

func delete_tiles():
  var mesh_dir = DirAccess.open(MESHES_PATH + name)
  if mesh_dir == null:
    print("Failed to open mesh directory for tileset: ", name)
    return
  mesh_dir.list_dir_begin()
  var file_name = mesh_dir.get_next()
  while file_name != "":
    mesh_dir.remove(file_name)
    file_name = mesh_dir.get_next()
  mesh_dir.list_dir_end()
  mesh_dir.change_dir("..")
  mesh_dir.remove(name)

func get_tile(index: int) -> Tile:
  if index < 0 or index >= tiles.size():
    print("Index out of bounds: ", index, " for tileset ", name)
    return null
  return tiles[index]

func get_size() -> int:
  return tiles.size()
