class_name Tile
extends RefCounted

var id = ""
var imagePath = ""
var objPath = ""
var stlPath = ""
var mesh: Mesh
var stlToMesh = StlToMesh.new()

func create_tile_from_json(json: Dictionary):
  id = json.get("id", "")
  if (id == ""):
    print("Tile id is empty")
  imagePath = json.get("imagePath", "")
  if (imagePath == ""):
    print("Tile imagePath is empty")
  objPath = json.get("objPath", "")
  stlPath = json.get("stlPath", "")
  if stlPath != "":
    if FileAccess.file_exists(stlPath):
      var startTime = Time.get_ticks_msec()
      mesh = stlToMesh.stlFileToArrayMesh(stlPath)
      var endTime = Time.get_ticks_msec()
      print("Imported ", id, " in ", endTime - startTime, " ms")
    else:
      print("STL file does not exist: ", stlPath)

