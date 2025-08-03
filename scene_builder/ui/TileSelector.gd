extends VBoxContainer

signal tile_selected(tile: Tile)

const TILE_UI_SCENE = preload("res://scene_builder/ui/Tile.tscn")

@export var margin: int = 81

var current_page: int = 0
var number_of_tile_buttons = 0
var selected_set: DragonbiteTileSet
var tile_container: VBoxContainer
var tile_view_models = []

@onready var page_control = $%PageControl

func _ready():
  tile_container = $%Tiles
  for i in range(number_of_tile_buttons):
    var tile_vm = TileViewModel.new()
    tile_vm.index = i
    tile_view_models.append(tile_vm)
    add_tile_button(i)

func add_tile_button(index: int):
  var tile_button = TILE_UI_SCENE.instantiate()
  tile_button.index = index
  tile_button.tile_pressed.connect(_on_button_pressed)
  tile_container.add_child(tile_button)

func set_selected_set(tile_set: DragonbiteTileSet):
  selected_set = tile_set
  current_page = 0
  update_view_models()

func update_view_models():
  # Add view models if necessary
  if number_of_tile_buttons > tile_view_models.size():
    for i in range(tile_view_models.size(), number_of_tile_buttons):
      var tile_vm = TileViewModel.new()
      tile_vm.index = i
      tile_view_models.append(tile_vm)
  # Remove extra view models
  if number_of_tile_buttons < tile_view_models.size():
    tile_view_models.resize(number_of_tile_buttons)

  if selected_set == null:
    for i in range(number_of_tile_buttons - 1):
      tile_view_models[i].hidden = true
    update_buttons()
    return
  for i in range(number_of_tile_buttons):
    var tile_vm = tile_view_models[i]
    var tile_idx = i + (current_page * number_of_tile_buttons)
    if tile_idx >= selected_set.get_size():
      tile_vm.hidden = true
      continue
    tile_vm.hidden = false
    tile_vm.tile = selected_set.get_tile(tile_idx)
  update_buttons()

func update_buttons():
  # Add/remove buttons if necessary
  var difference = tile_container.get_child_count() - number_of_tile_buttons
  if difference < 0:
    for i in range(tile_container.get_child_count(), number_of_tile_buttons):
      add_tile_button(i)
    difference = 0
  elif difference > 0:
    for i in range(tile_container.get_child_count() - 1, number_of_tile_buttons - 1, -1):
      tile_container.get_child(i).queue_free()

  # Difference is set to 0 above so the array index doesn't go out of bounds
  var currently_active_buttons = tile_container.get_child_count() - difference
  for i in range(currently_active_buttons):
    tile_container.get_child(i).update_state(tile_view_models[i])
  page_control.visible = currently_active_buttons < selected_set.get_size()

func _on_button_pressed(index: int):
  tile_selected.emit(tile_view_models[index].tile)

func number_of_pages() -> int:
  var pages: int = selected_set.get_size() / number_of_tile_buttons
  if selected_set.get_size() % number_of_tile_buttons > 0:
    return pages + 1
  return pages

func go_to_previous_page():
  current_page -= 1
  if current_page < 0:
    current_page = number_of_pages() - 1
  update_view_models()

func go_to_next_page():
  current_page += 1
  if current_page >= number_of_pages():
    current_page = 0
  update_view_models()

func on_first_resize():
  calculate_number_of_tiles(tile_container.size.y)
  update_view_models()
  tile_container.resized.disconnect(on_first_resize)

func on_viewport_resized(new_size: Vector2):
  calculate_number_of_tiles(new_size.y - margin)
  update_view_models()

func calculate_number_of_tiles(target_size: float = 0):
  var base_tile = TILE_UI_SCENE.instantiate()
  var new_number_of_tiles = int(
      (target_size - base_tile.size.y)
      / (base_tile.size.y + tile_container.get_theme_constant("separation"))
  ) + 1
  if new_number_of_tiles != number_of_tile_buttons:
    number_of_tile_buttons = new_number_of_tiles
    current_page = 0
    update_view_models()
