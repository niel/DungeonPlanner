class_name LoadSavedFiles
extends RefCounted

signal import_started(int)
signal tile_imported()

const setDefinitionsPath = "user://SetDefinitions/"
const tilePath = "user://Meshes/"

func import_tile_set_from_directory(path: String, setName: String):
  if SceneContext.get_set_names().has(setName):
    print("Tile set with name ", setName, " already exists")
    return
  var setDefinition := {}
  var splitPath = path.split("/")
  # Check path
  if splitPath.size() == 0:
    print("Attempted to load tile set at empty path")
    return
  var setDefinitionDir = DirAccess.open(path)
  if setDefinitionDir == null:
    print("Failed to open ", DirAccess.get_open_error())
    return
  var newSet := DragonbiteTileSet.new()
  # Get name
  newSet.name = setName
  setDefinition["name"] = setName
  # Get tiles and import stl files
  var tiles = []
  var stlFilePaths := setDefinitionDir.get_files()
  call_deferred("emit_import_started", stlFilePaths.size())
  for fileName in stlFilePaths:
    if fileName.get_extension() != "stl":
      continue
    var newTile = newSet.import_tile(path + "/" + fileName)
    var tileDefinition = {}
    tileDefinition["name"] = newTile.name
    tileDefinition["id"] = newTile.id
    tileDefinition["resPath"] = tilePath + setName + "/" + newTile.name + ".res"
    tiles.append(tileDefinition)
    call_deferred("emit_tile_imported")
  setDefinition["tiles"] = tiles
  # Save file
  var result = JSON.stringify(setDefinition, "  ")
  var setDefinitionJson = FileAccess.open(setDefinitionsPath + setName + ".json", FileAccess.WRITE)
  setDefinitionJson.store_string(result)
  setDefinitionJson.close()
  SceneContext.tileResources.add_set(newSet)

func emit_import_started(total_tiles: int):
  import_started.emit(total_tiles)

func emit_tile_imported():
  tile_imported.emit()