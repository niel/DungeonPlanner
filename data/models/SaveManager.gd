class_name SaveManager
extends Node

const SAVED_SCENES_PATH = "user://SavedScenes/"

var scenes: Array[Scene] = []

func _init():
  var dir = DirAccess.open("user://")
  if dir.dir_exists(SAVED_SCENES_PATH) == false:
    dir.make_dir(SAVED_SCENES_PATH)
  var saved_scenes_dir = DirAccess.open(SAVED_SCENES_PATH)
  saved_scenes_dir.list_dir_begin()
  var save_name = saved_scenes_dir.get_next() 
  while save_name != "":
    if save_name.ends_with(".json"):
      var scene = Scene.new()
      var without_suffix = save_name.trim_suffix(".json")
      scene.scene_name = without_suffix
      scene.data = load_scene_from_user(without_suffix)
      scenes.append(scene)
    save_name = saved_scenes_dir.get_next()
  saved_scenes_dir.list_dir_end()

func load_scene_from_json(file_path: String) -> SceneData:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
      return SceneData.new()
    var json_string = file.get_as_text()
    var parsed_scene = SceneData.new()
    parsed_scene.from_json(json_string)
    file.close()
    var file_name = file_path.get_file().trim_suffix(".json")
    parsed_scene.scene_name = file_name
    return parsed_scene

func load_scene_from_user(file_name: String) -> SceneData:
    var file = FileAccess.open(SAVED_SCENES_PATH + file_name + ".json", FileAccess.READ)
    if file == null:
      print("Failed to open saved scene:%s with error %s" % [file_name, str(FileAccess.get_open_error())])
      var new_scene = SceneData.new()
      new_scene.scene_name = file_name
      return new_scene
    var json_string = file.get_as_text()
    var parsed_scene = SceneData.new()
    parsed_scene.from_json(json_string)
    file.close()
    return parsed_scene

func import_server_json(json: Dictionary) -> SceneData:
    var new_scene = Scene.new()
    var parsed_scene = SceneData.new()
    new_scene.data = parsed_scene.from_server_json(json)
    new_scene.scene_name = parsed_scene.scene_name
    scenes.append(new_scene)
    save_scene_to_user(parsed_scene)
    return parsed_scene

func save_scene_to_user(scene: SceneData):
  var json_string = scene.to_json()
  var file = FileAccess.open(SAVED_SCENES_PATH + scene.scene_name + ".json", FileAccess.WRITE)
  file.store_string(json_string)
  file.close()

func delete_scene(file_name: String):
  var local_path = SAVED_SCENES_PATH + file_name + ".json"
  OS.move_to_trash(ProjectSettings.globalize_path(local_path))
  var idx = scenes.find_custom((func(s): return s.scene_name == file_name))
  while idx != -1:
    scenes.remove_at(idx)
    idx = scenes.find_custom((func(s): return s.scene_name == file_name))

func get_scene_path(file_name: String) -> String:
  return SAVED_SCENES_PATH + file_name + ".json"
