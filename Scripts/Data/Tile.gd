class_name Tile
extends RefCounted

enum TileStatus {CACHED, CREATED, NOT_FOUND}

var id = ""
var imagePath = ""
var stlPath = ""
var mesh: Mesh
var stlToMesh = StlToMesh.new()

func create_tile_from_json(json: Dictionary) -> TileStatus:
  id = json.get("id", "")
  if (id == ""):
    print("Tile id is empty")
  imagePath = json.get("imagePath", "")
  if (imagePath == ""):
    print("Tile imagePath is empty")
  stlPath = json.get("stlPath", "")
  if stlPath != "":
    var resPath = stlPath.replace("stl", "res").replace("res://", "user://")
    if FileAccess.file_exists(resPath):
      mesh = load(resPath)
      return TileStatus.CACHED
    if FileAccess.file_exists(stlPath):
      var startTime = Time.get_ticks_msec()
      mesh = stlToMesh.stlFileToArrayMesh(stlPath)
      var endTime = Time.get_ticks_msec()
      print("Imported ", id, " in ", endTime - startTime, " ms")
      var dir = DirAccess.open("user://")
      if dir.dir_exists(resPath.get_base_dir()) == false:
        dir.make_dir_recursive(resPath.get_base_dir())
      var saveStatus = ResourceSaver.save(mesh, resPath, ResourceSaver.FLAG_CHANGE_PATH)
      if (saveStatus != OK):
        print("Failed to save mesh to ", resPath, " with status ", saveStatus)
      return TileStatus.CREATED
    else:
      print("STL file does not exist: ", stlPath) 
  return TileStatus.NOT_FOUND

