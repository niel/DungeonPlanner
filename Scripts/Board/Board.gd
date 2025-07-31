extends Node3D

var space_scene = preload("res://Scenes/Space.tscn")

const startRows = 20
const startCols = 20
const spaceSize = 5

var boardNodes: Array = []
var hoveredSpace: Node3D
      
func create_board():
  const xOffset = float(startRows) / 2 * spaceSize * -1.0
  const zOffset = float(startCols) / 2 * spaceSize * -1.0
  for i in startRows:
    var newRow = []
    newRow.resize(startCols)
    boardNodes.append(newRow)
    for j in startCols:
      var newSpace: Node3D = space_scene.instantiate()
      newSpace.x = i
      newSpace.z = j
      add_child(newSpace)
      boardNodes[i][j] = newSpace
      newSpace.set_position(Vector3(spaceSize * i + xOffset, 0, spaceSize * j + zOffset))
      newSpace.space_hover_enter.connect(on_space_hover_enter)
      newSpace.space_hover_exit.connect(on_space_hover_exit)
      newSpace.space_clicked.connect(on_space_clicked)

func on_space_hover_enter(space: Node3D):
  hoveredSpace = space
  var spacePosition = Vector2(hoveredSpace.x, hoveredSpace.z)
  # Error if tile doesn't fit
  var hoverError = not SceneContext.does_selected_tile_fit(spacePosition)
  hoveredSpace.start_preview(SceneContext.get_selected_tile_context(), hoverError)

func on_space_hover_exit(space: Node3D):
  if hoveredSpace == space:
    hoveredSpace.end_preview()
    hoveredSpace = null
      
func on_space_clicked(space: Node3D, x: int, y: int):
  var selectedTileContext = SceneContext.get_selected_tile_context()
  if selectedTileContext.tile == null:
    return
  if not SceneContext.does_selected_tile_fit(Vector2(x, y)):
    return
  SceneContext.set_tile(x, y, selectedTileContext)
  space.set_tile(selectedTileContext)

func on_context_updated():
  if hoveredSpace != null:
    var spacePosition = Vector2(hoveredSpace.x, hoveredSpace.z)
    # Error if tile doesn't fit
    var hoverError = not SceneContext.does_selected_tile_fit(spacePosition)
    hoveredSpace.update_context(SceneContext.get_selected_tile_context(), hoverError)

func load_scene(scene: SceneData):
  if scene == null:
    return
  var updated = []
  for i in startRows:
    var newRow = []
    for j in startCols:
      newRow.append(false)
    updated.append(newRow)
  for tile in scene.tiles:
    var tileData = SceneContext.get_tile_from_id(tile.id)
    var tileContext = SceneContext.TileContext.new()
    tileContext.tile = tileData
    tileContext.rotation = tile.rotation
    tileContext.mesh = tileData.mesh
    boardNodes[tile.x][tile.z].set_tile(tileContext)
    updated[tile.x][tile.z] = true
  for i in startRows:
    for j in startCols:
      if !updated[i][j]:
        boardNodes[i][j].set_empty()
