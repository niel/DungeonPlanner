extends Node

class_name PlanningSceneContext

class TileContext:
  var rotation: Vector3
  var tile: Tile
  var mesh: Mesh

signal context_updated(TileContext)
signal import_started(int)
signal tile_imported()

const defaultRotation = Vector3.LEFT * 90
const savedScenePath = "user://SavedScenes/"
const setDefinitionsPath = "user://SetDefinitions/"
const nodePath = "PlanningContext"
const tilePath = "user://Meshes/"

var tileResourcesClass = preload("res://Scripts/Data/TileResources.gd")

var selectedTileContext: TileContext
var mainBoard: Node3D
var tileResources: TileResources
var currentScene: SceneData

func _ready():
  tileResources = tileResourcesClass.new()
  load_tileResources()
  selectedTileContext = TileContext.new()
  selectedTileContext.rotation = defaultRotation
  currentScene = SceneData.new()
  currentScene.sceneName = "New Scene"

static func get_instance(from: Node) -> PlanningSceneContext:
  return from.get_tree().get_root().get_node(nodePath)

func load_tileResources():
  var startTime = Time.get_ticks_msec()
  var setDefinitionsDir = DirAccess.open(setDefinitionsPath)
  if setDefinitionsDir == null:
    print("Failed to open ", setDefinitionsPath)
    return
  setDefinitionsDir.list_dir_begin()
  var fileName = setDefinitionsDir.get_next()
  while fileName != "":
    add_imported_tile_set(setDefinitionsPath + fileName)
    fileName = setDefinitionsDir.get_next()
  var endTime = Time.get_ticks_msec()
  setDefinitionsDir.list_dir_end()
  print("Resources loaded in ", (endTime - startTime) / 1000.0, " sec")  

func add_imported_tile_set(path: String):
  var fileContents = FileAccess.get_file_as_string(path)
  var parsedJson = JSON.parse_string(fileContents)
  tileResources.add_imported_set(parsedJson)

func import_tile_set_from_directory(path: String, setName: String):
  if get_set_names().has(setName):
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
  tileResources.add_set(newSet)

func emit_import_started(total_tiles: int):
  import_started.emit(total_tiles)

func emit_tile_imported():
  tile_imported.emit()

func get_selected_mesh() -> Mesh:
  return selectedTileContext.mesh

func set_selected_mesh(mesh: Mesh):
  selectedTileContext.mesh = mesh
  
func get_selected_tile_context() -> TileContext:
  return selectedTileContext

func get_set_names() -> Array:
  var setNames = []
  for tileSet in tileResources.tileSets:
    setNames.append(tileSet.name)
  return setNames
  
func left_rotation():
  selectedTileContext.rotation[1] += 90
  context_updated.emit()
  
func right_rotation():
  selectedTileContext.rotation[1] -= 90
  context_updated.emit()
  
func get_selected_rotation() -> Vector3:
  return selectedTileContext.rotation
  
func update_selected_tile(newSelected: Tile) :
  selectedTileContext.tile = newSelected
  if newSelected.mesh != null:
    selectedTileContext.mesh = newSelected.mesh
    print("Loaded mesh from tile")
  else:
    selectedTileContext.mesh = load(newSelected.objPath)
  if selectedTileContext.mesh == null:
    print("Failed to load mesh at ", newSelected.objPath)

func set_tile(x: int, z:int, tile: TileContext):
  currentScene.setTileAt(x, z, tile)

func set_current_scene(newScene: SceneData):
  currentScene = newScene
  
func get_tile_from_id(id:String) -> Tile:
  for tileSet in tileResources.tileSets:
    for tile in tileSet.tiles:
      if tile.id == id:
        return tile
  return null
