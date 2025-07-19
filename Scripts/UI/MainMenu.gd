extends PanelContainer

const delete_scene_confirmation_text = "Are you sure you want to delete %s?"
const planning_scene = preload("res://Scenes/PlannerScene.tscn")
const ui_recent_scene_item = preload("res://Scenes/UI/MainMenu/RecentSceneItem.tscn")

@onready var confirmationDialog: ConfirmationDialog = $ConfirmationDialog
var confirmationDialogTarget: String
@onready var context := PlanningSceneContext.get_instance(self)
@onready var importedSetsContainer: VBoxContainer = $%ImportedSets
@onready var importSet: MarginContainer = $%ImportTileSet
@onready var recentScenesContainer: VBoxContainer = $%RecentScenes
var saveManager := SaveManager.new()

func _ready():
  update_recent_scenes()
  update_imported_sets()

func update_recent_scenes():
  #Delete existing scenes
  for child in recentScenesContainer.get_children():
    child.queue_free()
  var recentScenes = saveManager.sceneNames
  for scene in recentScenes:
    var button = ui_recent_scene_item.instantiate()
    button.setText(scene)
    button.select_pressed.connect(load_recent_scene.bind(scene))
    button.delete_pressed.connect(delete_recent_scene.bind(scene))
    recentScenesContainer.add_child(button)

func update_imported_sets():
  var importedSets = context.get_set_names()
  for child in importedSetsContainer.get_children():
    child.queue_free()
  for importedSet in importedSets:
    var label = Label.new()
    label.text = importedSet
    importedSetsContainer.add_child(label)

func import_new_set(path: String, setName: String) -> void:
  context.import_tile_set_from_directory(path, setName)
  update_imported_sets()

func import_set_pressed():
  importSet.initialize()

func load_recent_scene(scene_name: String):
  var sceneData = saveManager.load_scene_from_json(scene_name)
  context.currentScene = sceneData
  change_to_planning_scene()

func delete_recent_scene(scene_name: String):
  confirmationDialogTarget = scene_name
  confirmationDialog.dialog_text = delete_scene_confirmation_text % confirmationDialogTarget
  confirmationDialog.popup_centered()
  update_recent_scenes()

func delete_scene_confirmed():
  print("Deleting scene: ", confirmationDialogTarget)
  saveManager.delete_scene(confirmationDialogTarget)
  update_recent_scenes()

func on_new_scene():
  change_to_planning_scene()

func change_to_planning_scene():
  var error = get_tree().change_scene_to_packed(planning_scene)
  if error != OK:
    print("Error loading planning scene: ", error)
