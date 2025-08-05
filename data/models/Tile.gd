class_name Tile
extends RefCounted

enum TileStatus {CACHED, CREATED, NOT_FOUND, CACHE_MISS}

var name = ""
var mesh_path: String = ""
var id: String = ""
var x_size: int = 0
var y_size: int = 0

func load_imported_tile(json: Dictionary) -> TileStatus:
  var res_path = json.get(DragonbiteTileSet.KEY_TILE_RES_PATH, "")
  if !FileAccess.file_exists(res_path):
    return TileStatus.CACHE_MISS
  name = json.get(DragonbiteTileSet.KEY_TILE_NAME, "")
  if (name == ""):
    print("Tile name is empty")
  id = json.get(DragonbiteTileSet.KEY_TILE_ID, "")
  if (id == ""):
    print("Tile ID is empty")
  mesh_path = res_path
  x_size = json.get(DragonbiteTileSet.KEY_TILE_X_SIZE, 1)
  y_size = json.get(DragonbiteTileSet.KEY_TILE_Y_SIZE, 1)
  return TileStatus.CACHED

func create_tile(source_path: String, destination_path: String) -> TileStatus:
  if !FileAccess.file_exists(source_path):
    print("Source file does not exist: ", source_path)
    return TileStatus.NOT_FOUND
  if FileAccess.file_exists(destination_path):
    print("Destination file already exists: ", destination_path)
    return TileStatus.CACHED
  var start_time = Time.get_ticks_msec()
  var stl_to_mesh = StlToMesh.new(source_path)
  var array_mesh: ArrayMesh = stl_to_mesh.mesh
  id = stl_to_mesh.mesh_hash
  x_size = stl_to_mesh.x_size
  y_size = stl_to_mesh.y_size
  var end_time = Time.get_ticks_msec()
  name = source_path.get_file().get_slice(".", 0)
  print("Imported ", name, " in ", end_time - start_time, " ms")
  var dir = DirAccess.open("user://")
  var destination_dir = destination_path.get_base_dir()
  if !dir.dir_exists(destination_dir):
    var res = dir.make_dir_recursive(destination_dir)
    if res != OK:
      print("Failed to create directory: ", destination_dir, " with error: ", res)
      return TileStatus.NOT_FOUND
  var save_status = ResourceSaver.save(array_mesh, destination_path, ResourceSaver.FLAG_CHANGE_PATH)
  if (save_status != OK):
    print("Failed to save mesh to ", destination_path, " with status ", save_status)
  return TileStatus.CREATED
