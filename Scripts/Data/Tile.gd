class_name Tile
extends RefCounted

enum TileStatus {CACHED, CREATED, NOT_FOUND, CACHE_MISS}

var name = ""
var mesh: Mesh
var id: String = ""

func  load_imported_tile(json: Dictionary):
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

