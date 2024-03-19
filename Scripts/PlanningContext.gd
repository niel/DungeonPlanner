extends Node

class TileContext:
	var rotation: Vector3
	var tile: Tile
	var mesh: Mesh

signal context_updated(TileContext)

var tileResourcesClass = preload("res://Scripts/Data/TileResources.gd")

var selectedTileContext: TileContext
var mainBoard: Node3D
var tile_resources

func initialize():
	tile_resources = tileResourcesClass.new()
	load_tile_resources()
	selectedTileContext = TileContext.new()
	selectedTileContext.rotation = Vector3.ZERO

func load_tile_resources():
	var cavernsSetDefinition = "res://TileDefinitions/MhCavernCore.json"
	var fileContents = FileAccess.get_file_as_string(cavernsSetDefinition)
	var parsedJson = JSON.parse_string(fileContents)
	tile_resources.add_set_from_json(parsedJson)

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
	selectedTileContext.mesh = load(newSelected.meshPath)
	print("Selected is ", selectedTileContext.tile.id)
