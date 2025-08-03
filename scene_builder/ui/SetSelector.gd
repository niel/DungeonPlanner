extends VBoxContainer

signal set_selected(set: DragonbiteTileSet)

const SET_BUTTON_SCENE = preload ("res://scene_builder/ui/SetButton.tscn")

@export var margin: int = 81

var current_page: int = 0
var number_of_set_buttons: int = 0
var selectable_sets: Array = []
var set_view_models = []
var set_container: VBoxContainer

@onready var page_control = $%PageControl

func _ready():
  set_container = $Sets
  for i in range(number_of_set_buttons):
    var set_vm = SetViewModel.new()
    set_vm.index = i
    set_view_models.append(set_vm)
    add_set_button(i)

func add_set_button(index: int):
  var set_button = SET_BUTTON_SCENE.instantiate()
  set_button.index = index
  set_button.set_button_pressed.connect(_on_button_pressed)
  set_container.add_child(set_button)

func set_selectable_sets(sets: Array):
  selectable_sets = sets
  update_view_models()

func update_view_models():
  # Add view models if necessary
  if number_of_set_buttons > set_view_models.size():
    for i in range(set_view_models.size(), number_of_set_buttons):
      var set_vm = SetViewModel.new()
      set_vm.index = i
      set_view_models.append(set_vm)
  # Remove extra view models
  if number_of_set_buttons < set_view_models.size():
    set_view_models.resize(number_of_set_buttons)

  if selectable_sets.size() == 0:
    for i in range(number_of_set_buttons - 1):
      set_view_models[i].hidden = true
    update_buttons()
    return
  for i in range(number_of_set_buttons):
    var set_vm = set_view_models[i]
    var set_idx = i + (current_page * number_of_set_buttons)
    if set_idx >= selectable_sets.size():
      set_vm.hidden = true
      continue
    set_vm.hidden = false
    set_vm.tile_set = selectable_sets[set_idx]
  update_buttons()

func update_buttons():
  # Add/remove buttons if necessary
  var difference = set_container.get_child_count() - number_of_set_buttons
  if difference < 0:
    for i in range(set_container.get_child_count(), number_of_set_buttons):
      add_set_button(i)
    difference = 0
  elif difference > 0:
    for i in range(set_container.get_child_count() - 1, number_of_set_buttons - 1, -1):
      set_container.get_child(i).queue_free()

  # Difference is set to 0 above so the array index doesn't go out of bounds
  var currently_active_buttons = set_container.get_child_count() - difference
  for i in range(currently_active_buttons):
    set_container.get_child(i).update_state(set_view_models[i])
  page_control.visible = currently_active_buttons < selectable_sets.size()

func _on_button_pressed(set_index: int):
  set_selected.emit(set_view_models[set_index].tile_set)

func number_of_pages() -> int:
  var pages: int = selectable_sets.size() / number_of_set_buttons
  if selectable_sets.size() % number_of_set_buttons > 0:
    return pages + 1
  return pages

func on_previous_pressed():
  current_page -= 1
  if current_page < 0:
    current_page = number_of_pages() - 1
  update_view_models()

func on_next_pressed():
  current_page += 1
  if current_page >= number_of_pages():
    current_page = 0
  update_view_models()

func on_first_resize():
  calculate_number_of_tiles(set_container.size.y)
  update_view_models()
  set_container.resized.disconnect(on_first_resize)

func on_viewport_resized(new_size: Vector2):
  calculate_number_of_tiles(new_size.y - margin)
  update_view_models()

func calculate_number_of_tiles(target_size: float = 0):
  var base_set = SET_BUTTON_SCENE.instantiate()
  var new_number_of_sets = int(
    (target_size - base_set.size.y)
    / (base_set.size.y + set_container.get_theme_constant("separation"))
  ) + 1
  if new_number_of_sets != number_of_set_buttons:
    number_of_set_buttons = new_number_of_sets
    current_page = 0
    update_view_models()
