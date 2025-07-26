extends Node

class_name SaveManager

const savedScenesPath = "user://SavedScenes/"

var sceneNames: Array[String] = []

func _init():
  var dir = DirAccess.open("user://")
  if dir.dir_exists(savedScenesPath) == false:
    dir.make_dir(savedScenesPath)
  var savedScenesDir = DirAccess.open(savedScenesPath)
  savedScenesDir.list_dir_begin()
  var saveName = savedScenesDir.get_next()
  while saveName != "":
    if saveName.ends_with(".json"):
      sceneNames.append(saveName.replace(".json", ""))
    saveName = savedScenesDir.get_next()
  savedScenesDir.list_dir_end()

func load_scene_from_json(file_path: String) -> SceneData:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
      return SceneData.new()
    var jsonString = file.get_as_text()
    var parsedScene = SceneData.new()
    parsedScene.fromJson(jsonString, PlanningSceneContext.get_instance(self))
    file.close()
    var fileName = file_path.get_file().trim_suffix(".json")
    parsedScene.sceneName = fileName
    return parsedScene

func load_scene_from_user(file_name: String) -> SceneData:
    var file = FileAccess.open(savedScenesPath + file_name + ".json", FileAccess.READ)
    if file == null:
      var newScene = SceneData.new()
      newScene.sceneName = file_name
      return newScene
    var jsonString = file.get_as_text()
    var parsedScene = SceneData.new()
    parsedScene.fromJson(jsonString, PlanningSceneContext.get_instance(self))
    file.close()
    return parsedScene

func save_scene_to_user(scene: SceneData):
  var jsonString = scene.toJson()
  var file = FileAccess.open(savedScenesPath + scene.sceneName + ".json", FileAccess.WRITE)
  file.store_string(jsonString)
  file.close()

func delete_scene(file_name: String):
  var localPath = savedScenesPath + file_name + ".json"
  OS.move_to_trash(ProjectSettings.globalize_path(localPath))
  sceneNames.erase(file_name)
