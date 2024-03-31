extends Node3D

var space_scene = preload("res://Scenes/Space.tscn")

const startRows = 10
const startCols = 10
const spaceSize = 5

var board:Array = []
var hoveredSpace: Node3D
var context: PlanningContext

# Called when the node enters the scene tree for the first time.
func connect_to_context(newContext: PlanningContext):
  context = newContext
  context.context_updated.connect(on_context_updated)
      
func create_board():
  const xOffset = float(startRows) / 2 * spaceSize * -1.0
  const zOffset = float(startCols) / 2 * spaceSize * -1.0
  for i in startRows:
    var newRow = []
    newRow.resize(startCols)
    board.append(newRow)
    for j in startCols:
      var newSpace: Node3D = space_scene.instantiate()
      newSpace.x = i
      newSpace.z = j
      add_child(newSpace)
      board[i][j] = newSpace
      newSpace.set_position(Vector3(spaceSize * i + xOffset, 0, spaceSize * j + zOffset))
      newSpace.space_hover_enter.connect(on_space_hover_enter)
      newSpace.space_hover_exit.connect(on_space_hover_exit)
      newSpace.space_clicked.connect(on_space_clicked)

func on_space_hover_enter(space: Node3D):
  hoveredSpace = space
  hoveredSpace.start_preview(context.selectedTileContext)

func on_space_hover_exit(space: Node3D):
  if hoveredSpace == space:
    hoveredSpace.end_preview()
    hoveredSpace = null
      
func on_space_clicked(space: Node3D, x: int, y: int):
  space.set_tile(context.get_selected_tile_context())
  context.set_tile(x, y, context.get_selected_tile_context())

func on_context_updated():
  if hoveredSpace != null:
    hoveredSpace.update_context(context.get_selected_tile_context())

func rotate_degrees(degrees: int):
  print(degrees)
  pass

func load_scene(scene:SavedScene):
  var updated = []
  for i in startRows:
    var newRow = []
    for j in startCols:
      newRow.append(false)
    updated.append(newRow)
  for tile in scene.tiles:
    var tileData = context.get_tile_from_id(tile.id)
    var tileContext = PlanningContext.TileContext.new()
    tileContext.tile = tileData
    tileContext.rotation = tile.rotation
    tileContext.mesh = tileData.mesh
    board[tile.x][tile.z].set_tile(tileContext)
    updated[tile.x][tile.z] = true
  for i in startRows:
    for j in startCols:
      if !updated[i][j]:
        board[i][j].set_empty()
