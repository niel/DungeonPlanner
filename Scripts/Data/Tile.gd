class_name Tile
extends RefCounted

enum TileStatus {CACHED, CREATED, NOT_FOUND, CACHE_MISS}

const missingImagePath = "res://Images/Missing.png"

var id = ""
var imagePath = ""
var mesh: Mesh
var stlToMesh = StlToMesh.new()

func load_imported_tile(json: Dictionary):
  var resPath = json.get("resPath", "")
  if !FileAccess.file_exists(resPath):
    return TileStatus.CACHE_MISS
  id = json.get("id", "")
  if (id == ""):
    print("Tile id is empty")
  imagePath = json.get("imagePath", "")
  if (imagePath == ""):
    imagePath = missingImagePath
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
  mesh = stlToMesh.stlFileToArrayMesh(sourcePath)
  var endTime = Time.get_ticks_msec()
  id = sourcePath.get_file().get_slice(".", 0)
  print("Imported ", id, " in ", endTime - startTime, " ms")
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

