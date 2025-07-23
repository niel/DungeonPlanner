extends Control

signal tile_selected(tile: Tile)

const tileUi = preload("res://Scenes/UI/Tile.tscn")
const numberOfTiles = 25

var selectedSet: DragonbiteTileSet
var currentPage: int = 0
var tileViewModels = []

@onready var tileContainer = $TileSelector/Tiles

func _ready():
  for i in range(numberOfTiles):
    var tileVM = TileViewModel.new()
    tileVM.index = i
    tileViewModels.append(tileVM)

    var tileButton = tileUi.instantiate()
    tileButton.index = i
    tileButton.tile_pressed.connect(_on_button_pressed)
    tileContainer.add_child(tileButton)

func set_selected_set(tileSet: DragonbiteTileSet):
  selectedSet = tileSet
  currentPage = 0
  update_view_models()
  update_buttons()

func update_view_models():
  for i in range(numberOfTiles):
    var tileVM = tileViewModels[i]
    var tileIdx = i + (currentPage * numberOfTiles)
    if tileIdx >= selectedSet.get_size():
      tileVM.hidden = true
      continue
    tileVM.hidden = false
    tileVM.tile = selectedSet.get_tile(tileIdx)
  update_buttons()

func update_buttons():
  for i in range(numberOfTiles):
    var tileNode = tileContainer.get_child(i)
    tileNode.update_state(tileViewModels[i])

func _on_button_pressed(index: int):
  tile_selected.emit(tileViewModels[index].tile)

func number_of_pages() -> int:
  var pages: int = selectedSet.get_size() / numberOfTiles
  if selectedSet.get_size() % numberOfTiles > 0:
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
