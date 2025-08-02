class_name Tile
extends RefCounted

enum TileStatus {CACHED, CREATED, NOT_FOUND, CACHE_MISS}

var name = ""
var mesh: Mesh
var id: String = ""
var x_size: int = 0
var y_size: int = 0

func  load_imported_tile(json: Dictionary) -> TileStatus:
  var resPath = json.get(DragonbiteTileSet.keyTileResPath, "")
  if !FileAccess.file_exists(resPath):
    return TileStatus.CACHE_MISS
  name = json.get(DragonbiteTileSet.keyTileName, "")
  if (name == ""):
    print("Tile name is empty")
  id = json.get(DragonbiteTileSet.keyTileId, "")
  if (id == ""):
    print("Tile ID is empty")
  mesh = load(resPath) 
  x_size = json.get(DragonbiteTileSet.keyTileXSize, 1)
  y_size = json.get(DragonbiteTileSet.keyTileYSize, 1)
  return TileStatus.CACHED

func create_tile(sourcePath: String, destinationPath: String) -> TileStatus:
  if !FileAccess.file_exists(sourcePath):
    print("Source file does not exist: ", sourcePath)
    return TileStatus.NOT_FOUND
  if FileAccess.file_exists(destinationPath):
    print("Destination file already exists: ", destinationPath)
    return TileStatus.CACHED
  var startTime = Time.get_ticks_msec()
  var stlToMesh = StlToMesh.new(sourcePath)
  mesh = stlToMesh.mesh
  id = stlToMesh.mesh_hash
  x_size = stlToMesh.x_size
  y_size = stlToMesh.y_size
  var endTime = Time.get_ticks_msec()
  name = sourcePath.get_file().get_slice(".", 0)
  print("Imported ", name, " in ", endTime - startTime, " ms")
  var dir = DirAccess.open("user://")
  var destinationDir = destinationPath.get_base_dir()
  if !dir.dir_exists(destinationDir):
    var res = dir.make_dir_recursive(destinationDir)
    if res != OK:
      print("Failed to create directory: ", destinationDir, " with error: ", res)
      return TileStatus.NOT_FOUND
  var saveStatus = ResourceSaver.save(mesh, destinationPath, ResourceSaver.FLAG_CHANGE_PATH)
  if (saveStatus != OK):
    print("Failed to save mesh to ", destinationPath, " with status ", saveStatus)
  return TileStatus.CREATED

