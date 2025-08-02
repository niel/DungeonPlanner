extends VBoxContainer

signal tile_selected(tile: Tile)

const tileUi = preload("res://scene_builder/ui/Tile.tscn")

var currentPage: int = 0
var numberOfTileButtons = 0
@onready var pageControl = $%PageControl
var selectedSet: DragonbiteTileSet
var tileContainer: VBoxContainer
var tileViewModels = []
@export var margin: int = 81

func _ready():
  tileContainer = $%Tiles
  for i in range(numberOfTileButtons):
    var tileVM = TileViewModel.new()
    tileVM.index = i
    tileViewModels.append(tileVM)
    add_tile_button(i)

func add_tile_button(index: int):
  var tileButton = tileUi.instantiate()
  tileButton.index = index
  tileButton.tile_pressed.connect(_on_button_pressed)
  tileContainer.add_child(tileButton)

func set_selected_set(tileSet: DragonbiteTileSet):
  selectedSet = tileSet
  currentPage = 0
  update_view_models()

func update_view_models():
  # Add view models if necessary
  if numberOfTileButtons > tileViewModels.size():
    for i in range(tileViewModels.size(), numberOfTileButtons):
      var tileVM = TileViewModel.new()
      tileVM.index = i
      tileViewModels.append(tileVM)
  # Remove extra view models
  if numberOfTileButtons < tileViewModels.size():
    tileViewModels.resize(numberOfTileButtons)

  if selectedSet == null:
    for i in range(numberOfTileButtons - 1):
      tileViewModels[i].hidden = true
    update_buttons()
    return
  for i in range(numberOfTileButtons):
    var tileVM = tileViewModels[i]
    var tileIdx = i + (currentPage * numberOfTileButtons)
    if tileIdx >= selectedSet.get_size():
      tileVM.hidden = true
      continue
    tileVM.hidden = false
    tileVM.tile = selectedSet.get_tile(tileIdx)
  update_buttons()

func update_buttons():
  # Add/remove buttons if necessary
  var difference = tileContainer.get_child_count() - numberOfTileButtons
  if difference < 0:
    for i in range(tileContainer.get_child_count(), numberOfTileButtons):
      add_tile_button(i)
    difference = 0
  elif difference > 0:
    for i in range(tileContainer.get_child_count() - 1, numberOfTileButtons - 1, -1):
      tileContainer.get_child(i).queue_free()

  # Difference is set to 0 above so the array index doesn't go out of bounds
  var currentlyActiveButtons = tileContainer.get_child_count() - difference
  for i in range(currentlyActiveButtons):
    tileContainer.get_child(i).update_state(tileViewModels[i])
  pageControl.visible = currentlyActiveButtons < selectedSet.get_size()

func _on_button_pressed(index: int):
  tile_selected.emit(tileViewModels[index].tile)

func number_of_pages() -> int:
  var pages: int = selectedSet.get_size() / numberOfTileButtons
  if selectedSet.get_size() % numberOfTileButtons > 0:
    return pages + 1
  return pages

func go_to_previous_page():
  currentPage -= 1
  if currentPage < 0:
    currentPage = number_of_pages() - 1
  update_view_models()

func go_to_next_page():
  currentPage += 1
  if currentPage >= number_of_pages():
    currentPage = 0
  update_view_models()
  
func on_first_resize():
  calculate_number_of_tiles(tileContainer.size.y)
  update_view_models()
  tileContainer.resized.disconnect(on_first_resize)

func on_viewport_resized(newSize: Vector2):
  calculate_number_of_tiles(newSize.y - margin)
  update_view_models()

func calculate_number_of_tiles(targetSize: float = 0):
  var baseTile = tileUi.instantiate()
  var newNumberOfTiles = int((targetSize - baseTile.size.y) / (baseTile.size.y + tileContainer.get_theme_constant("separation"))) + 1
  if newNumberOfTiles != numberOfTileButtons:
    numberOfTileButtons = newNumberOfTiles
    currentPage = 0
    update_view_models()
