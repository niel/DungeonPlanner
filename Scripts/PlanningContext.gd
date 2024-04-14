extends Node

class_name PlanningSceneContext

class TileContext:
  var rotation: Vector3
  var tile: Tile
  var mesh: Mesh

signal context_updated(TileContext)

const setDefinitionsPath = "res://TileDefinitions/"
const defaultRotation = Vector3.LEFT * 90
const savedScenePath = "user://SavedScenes/"
const savedSceneName = "testScene.json"

var tileResourcesClass = preload("res://Scripts/Data/TileResources.gd")

var selectedTileContext: TileContext
var mainBoard: Node3D
var tileResources: TileResources
var currentScene: SceneData

func initialize():
  tileResources = tileResourcesClass.new()
  load_tileResources()
  selectedTileContext = TileContext.new()
  selectedTileContext.rotation = defaultRotation
  currentScene = SceneData.new()
  currentScene.sceneName = "New Scene"

func load_tileResources():
  var startTime = Time.get_ticks_msec()
  var setDefinitionsDir = DirAccess.open(setDefinitionsPath)
  if setDefinitionsDir == null:
    print("Failed to open ", setDefinitionsPath)
    return
  setDefinitionsDir.list_dir_begin()
  var fileName = setDefinitionsDir.get_next()
  while fileName != "":
    add_tile_set_at_path(setDefinitionsPath + fileName)
    fileName = setDefinitionsDir.get_next()
  var endTime = Time.get_ticks_msec()
  setDefinitionsDir.list_dir_end()
  print("Resources loaded in ", (endTime - startTime) / 1000.0, " sec")

func add_tile_set_at_path(path: String):
  var fileContents = FileAccess.get_file_as_string(path)
  var parsedJson = JSON.parse_string(fileContents)
  tileResources.add_set_from_json(parsedJson)

func get_selected_mesh() -> Mesh:
  return selectedTileContext.mesh

func set_selected_mesh(mesh: Mesh):
  selectedTileContext.mesh = mesh
  
func get_selected_tile_context() -> TileContext:
  return selectedTileContext
  
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