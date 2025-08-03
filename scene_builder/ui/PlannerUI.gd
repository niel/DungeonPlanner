extends MarginContainer

class UIContext:
  var current_scene: String = ""
  var recent_scenes: Array[String] = []

signal tile_selected(tile: Tile)
signal new_scene()
signal save_current_scene(scene_name: String)
signal load_scene(scene_name: String)
signal quit_scene()

const UNSAVED_CHANGES_DONT_SAVE_ACTION: StringName = "dont_save"

var context: UIContext
var resources: TileResources
var unsaved_changes: bool = false

@onready var tile_selector_node = $%TileSelectorControl
@onready var set_selector_node = $%SetSelectorControl
@onready var menu_bar = $%MenuBar
@onready var file_button = $%FileButton
@onready var save_as_dialog = $%SaveAsDialogControl
@onready var unsaved_changes_dialog = $%UnsavedChangesDialog
@onready var unsaved_changes_save_as_dialog = $%UnsavedChangesSaveAsDialog

func _ready():
  tile_selector_node.tile_selected.connect(set_selected_tile)
  set_selector_node.set_selected.connect(set_selected_set)
  file_button.new_scene.connect(_on_file_new)
  file_button.load_scene.connect(_on_file_load)
  file_button.save_scene.connect(_on_file_save)
  file_button.save_scene_as.connect(show_save_as_dialog)
  file_button.quit_scene.connect(on_quit)
  save_as_dialog.saved_with_name.connect(_on_save_as)
  context = UIContext.new()
  if SceneContext.current_scene != null:
    context.current_scene = SceneContext.current_scene.scene_name

func set_tile_resources(new_resources: TileResources):
  resources = new_resources
  set_selected_set(resources.tile_sets[0])
  set_selector_node.set_selectable_sets(resources.tile_sets)

func set_selected_tile(tile: Tile):
  tile_selected.emit(tile)

func set_selected_set(tile_set: DragonbiteTileSet):
  tile_selector_node.set_selected_set(tile_set)

func set_save_names(names: Array[String]):
  context.recent_scenes = names
  file_button.set_saves(context.recent_scenes)

func _on_file_new():
  context.current_scene = ""
  new_scene.emit()

func _on_file_load(scene_name: String):
  context.current_scene = scene_name
  load_scene.emit(scene_name)

func _on_file_save():
  if context.current_scene == "":
    show_save_as_dialog()
    return
  unsaved_changes = false
  save_current_scene.emit(context.current_scene)

func show_save_as_dialog():
  save_as_dialog.visible = true

func _on_save_as(scene_name: String):
  context.current_scene = scene_name
  unsaved_changes = false
  save_current_scene.emit(context.current_scene)
  file_button.set_saves(context.recent_scenes)

func on_quit():
  if unsaved_changes:
    unsaved_changes_dialog.visible = true
  else:
    quit_scene.emit()

func on_viewport_resized(new_size: Vector2):
  set_selector_node.on_viewport_resized(new_size)
  tile_selector_node.on_viewport_resized(new_size)

func on_board_tile_placed() -> void:
  unsaved_changes = true

func unsaved_changes_save():
  if SceneContext.current_scene.scene_name == "":
    unsaved_changes_save_as_dialog.visible = true
  else:
    save_current_scene.emit(SceneContext.current_scene.scene_name)
    quit_scene.emit()

func unsaved_changes_custom(action: StringName):
  if UNSAVED_CHANGES_DONT_SAVE_ACTION == action:
    quit_scene.emit()
  else:
    print("Unknown unsaved changes action: ", action)

func on_unsaved_changes_save_as_dialog_saved(scene_name: String) -> void:
  SceneContext.current_scene.scene_name = scene_name
  save_current_scene.emit(SceneContext.current_scene.scene_name)
  quit_scene.emit()
