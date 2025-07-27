class_name SceneContext
extends Node

class TileContext:
  var rotation: Vector3
  var tile: Tile
  var mesh: Mesh

const defaultRotation = Vector3.LEFT * 90
const savedScenePath = "user://SavedScenes/"
const setDefinitionsPath = "user://SetDefinitions/"
const nodePath = "PlanningContext"
const userDir = "user://"

static var selectedTileContext: TileContext
static var mainBoard: Node3D
static var tileResources: TileResources
static var currentScene: SceneData

static func initialize():
  var userDirAccess = DirAccess.open(userDir)
  if not userDirAccess.dir_exists(savedScenePath):
    userDirAccess.make_dir_recursive(savedScenePath)
  if not userDirAccess.dir_exists(setDefinitionsPath):
    userDirAccess.make_dir_recursive(setDefinitionsPath)
  tileResources = TileResources.new()
  load_tileResources()
  selectedTileContext = TileContext.new()
  selectedTileContext.rotation = defaultRotation
  currentScene = SceneData.new()
  currentScene.sceneName = "New Scene"

static func get_instance(from: Node) -> SceneContext:
  return from.get_tree().root.get_node_or_null(nodePath) as SceneContext

static func load_tileResources():
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

static func add_imported_tile_set(path: String):
  var fileContents = FileAccess.get_file_as_string(path)
  var parsedJson = JSON.parse_string(fileContents)
  tileResources.add_imported_set(parsedJson)

static func get_selected_mesh() -> Mesh:
  return selectedTileContext.mesh

static func set_selected_mesh(mesh: Mesh):
  selectedTileContext.mesh = mesh

static func get_selected_tile_context() -> TileContext:
  return selectedTileContext

static func get_set_names() -> Array:
  var setNames = []
  for tileSet in tileResources.tileSets:
    setNames.append(tileSet.name)
  return setNames
  
static func left_rotation():
  selectedTileContext.rotation[1] += 90
  
static func right_rotation():
  selectedTileContext.rotation[1] -= 90

static func get_selected_rotation() -> Vector3:
  return selectedTileContext.rotation
  
static func update_selected_tile(newSelected: Tile):
  selectedTileContext.tile = newSelected
  if newSelected.mesh != null:
    selectedTileContext.mesh = newSelected.mesh
  else:
    selectedTileContext.mesh = load(newSelected.objPath)
  if selectedTileContext.mesh == null:
    print("Failed to load mesh at ", newSelected.objPath)

static func set_tile(x: int, z: int, tile: TileContext):
  currentScene.setTileAt(x, z, tile)

static func set_current_scene(newScene: SceneData):
  currentScene = newScene

static func get_tile_from_id(id: String) -> Tile:
  for tileSet in tileResources.tileSets:
    for tile in tileSet.tiles:
      if tile.id == id:
        return tile
  return null
