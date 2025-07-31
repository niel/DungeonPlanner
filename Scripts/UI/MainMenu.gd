extends PanelContainer

const delete_scene_confirmation_text = "Are you sure you want to delete %s?"
const planning_scene = preload("res://Scenes/PlannerScene.tscn")
const ui_recent_scene_item = preload("res://Scenes/UI/MainMenu/RecentSceneItem.tscn")

@onready var confirmationDialog: ConfirmationDialog = $ConfirmationDialog
var confirmationDialogTarget: String
@onready var exportDestinationSelectDialog: FileDialog = $ExportDestinationSelectDialog
var exportSceneName: String = ""
@onready var importedSetsContainer: VBoxContainer = $%ImportedSets
@onready var importSet: MarginContainer = $%ImportTileSet
@onready var recentScenesContainer: VBoxContainer = $%RecentScenes
@onready var sceneImportDialog: FileDialog = $%SceneImportDialog
var saveManager := SaveManager.new()

func _ready():
  SceneContext.initialize()
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
    button.export_pressed.connect(export_recent_scene.bind(scene))
    button.delete_pressed.connect(delete_recent_scene.bind(scene))
    recentScenesContainer.add_child(button)

func update_imported_sets():
  var importedSets = SceneContext.get_set_names()
  for child in importedSetsContainer.get_children():
    child.queue_free()
  for importedSet in importedSets:
    var label = Label.new()
    label.text = importedSet
    importedSetsContainer.add_child(label)

func import_set_pressed():
  importSet.initialize()

func load_recent_scene(scene_name: String):
  var sceneData = saveManager.load_scene_from_user(scene_name)
  SceneContext.get_instance(self).currentScene = sceneData
  change_to_planning_scene()

func export_recent_scene(scene_name: String):
  exportSceneName = scene_name
  exportDestinationSelectDialog.popup_centered()

func export_scene_at_path(export_path: String):
  print("Tested, exporting scene to: ", export_path)
  var scenePath = saveManager.get_scene_path(exportSceneName)
  var file = FileAccess.open(scenePath, FileAccess.READ)
  var exportFile = FileAccess.open(export_path, FileAccess.WRITE)
  if file == null:
    print("Error opening scene file.")
    return
  if exportFile == null:
    print("Error opening export file.")
    return
  exportFile.store_string(file.get_as_text())
  exportFile.close()
  file.close()

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
  SceneContext.get_instance(self).currentScene = SceneData.new()
  change_to_planning_scene()

func change_to_planning_scene():
  var error = get_tree().change_scene_to_packed(planning_scene)
  if error != OK:
    print("Error loading planning scene: ", error)

func _on_import_scene_pressed() -> void:
  sceneImportDialog.popup_centered()

func _on_scene_import_dialog_file_selected(path: String) -> void:
  var sceneData = saveManager.load_scene_from_json(path)
  SceneContext.get_instance(self).currentScene = sceneData
  saveManager.save_scene_to_user(sceneData)
  change_to_planning_scene()
