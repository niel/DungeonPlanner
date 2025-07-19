extends Node

class_name PlanningSceneContext

class TileContext:
  var rotation: Vector3
  var tile: Tile
  var mesh: Mesh

signal context_updated(TileContext)

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
  # Get name
  setDefinition["name"] = setName
  # Get tiles
  var tiles = []
  var stlFilePaths := setDefinitionDir.get_files()
  for fileName in stlFilePaths:
    if fileName.get_extension() != "stl":
      continue
    var tileDefinition = {}
    var id = fileName.get_file().get_slice(".", 0)
    tileDefinition["id"] = id
    tileDefinition["resPath"] = tilePath + setName + "/" + id + ".res"
    tiles.append(tileDefinition)
  setDefinition["tiles"] = tiles
  # Save file
  var result = JSON.stringify(setDefinition, "  ")
  var setDefinitionJson = FileAccess.open(setDefinitionsPath + setName + ".json", FileAccess.WRITE)
  setDefinitionJson.store_string(result)
  setDefinitionJson.close()
  # Import stl files
  var fullPaths = []
  for fileName in stlFilePaths:
    if fileName.get_extension() != "stl":
      continue
    var fullPath = path + "/" + fileName
    fullPaths.append(fullPath)
  tileResources.import_set(setName, fullPaths)

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
