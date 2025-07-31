extends VBoxContainer

signal set_selected(set: DragonbiteTileSet)

const setButtonScene = preload ("res://Scenes/UI/SetButton.tscn")
const setCount = 15

var currentPage: int = 0
var numberOfSetButtons: int = 0
var selectableSets: Array = []
var setViewModels = []
var setContainer: VBoxContainer
@export var margin: int = 81

func _ready():
  setContainer = $Sets
  for i in range(numberOfSetButtons):
    var setVm = SetViewModel.new()
    setVm.index = i
    setViewModels.append(setVm)
    add_set_button(i)

func add_set_button(index: int):
  var setButton = setButtonScene.instantiate()
  setButton.index = index
  setButton.set_button_pressed.connect(_on_button_pressed)
  setContainer.add_child(setButton)

func set_selectable_sets(sets: Array):
  selectableSets = sets
  update_view_models()

func update_view_models():
  # Add view models if necessary
  if numberOfSetButtons > setViewModels.size():
    for i in range(setViewModels.size(), numberOfSetButtons):
      var setVm = SetViewModel.new()
      setVm.index = i
      setViewModels.append(setVm)
  # Remove extra view models
  if numberOfSetButtons < setViewModels.size():
    setViewModels.resize(numberOfSetButtons)

  if selectableSets.size() == 0:
    for i in range(numberOfSetButtons - 1):
      setViewModels[i].hidden = true
    update_buttons()
    return
  for i in range(numberOfSetButtons):
    var setVm = setViewModels[i]
    var setIdx = i + (currentPage * numberOfSetButtons)
    if setIdx >= selectableSets.size():
      setVm.hidden = true
      continue
    setVm.hidden = false
    setVm.tileSet = selectableSets[setIdx]
  update_buttons()

func update_buttons():
  # Add/remove buttons if necessary
  var difference = setContainer.get_child_count() - numberOfSetButtons
  if difference < 0:
    for i in range(setContainer.get_child_count(), numberOfSetButtons):
      add_set_button(i)
    difference = 0
  elif difference > 0:
    for i in range(setContainer.get_child_count() - 1, numberOfSetButtons - 1, -1):
      setContainer.get_child(i).queue_free()

  # Difference is set to 0 above so the array index doesn't go out of bounds
  for i in range(setContainer.get_child_count() - difference):
    setContainer.get_child(i).update_state(setViewModels[i])

func _on_button_pressed(setIndex: int):
  set_selected.emit(setViewModels[setIndex].tileSet)

func number_of_pages() -> int:
  var pages: int = selectableSets.size() / numberOfSetButtons
  if selectableSets.size() % numberOfSetButtons > 0:
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
  calculate_number_of_tiles(setContainer.size.y)
  update_view_models()
  setContainer.resized.disconnect(on_first_resize)

func on_viewport_resized(newSize: Vector2):
  calculate_number_of_tiles(newSize.y - margin)
  update_view_models()

func calculate_number_of_tiles(targetSize: float = 0):
  var baseSet = setButtonScene.instantiate()
  print("Set size: ", baseSet.size, " separator size: ", setContainer.get_theme_constant("separation"), " Set container size: ", setContainer.size)
  var newNumberOfSets = int((targetSize - baseSet.size.y) / (baseSet.size.y + setContainer.get_theme_constant("separation"))) + 1
  print("Calculated number of sets: ", newNumberOfSets)
  if newNumberOfSets != numberOfSetButtons:
    numberOfSetButtons = newNumberOfSets
    currentPage = 0
    update_view_models()
