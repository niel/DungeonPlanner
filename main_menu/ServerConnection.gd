extends Node

signal new_scene_list(scenes: Array)

const SERVER_URL = "http://localhost:8080/scenes/list"

@onready var http_request = $"HTTPRequest"

func _ready() -> void:
  http_request.request_completed.connect(handle_scene_list)
  http_request.request(SERVER_URL)

func handle_scene_list(_result, _response_code, _headers, body: PackedByteArray) -> void:
  var json: Array = JSON.parse_string(body.get_string_from_utf8())
  var scenes: Array = []
  for scene_json in json:
    var scene_data = Scene.new()
    if scene_json.has("id"):
      scene_data.id = scene_json.id
    else:
      # No id, can't process scene
      continue
    if scene_json.has("name"):
      scene_data.scene_name = scene_json.name
    else:
      scene_data.scene_name = "Untitled"
    if scene_json.has("author"):
      scene_data.author = scene_json.author
    else:
      scene_data.author = "Unknown author"
    if scene_json.has("uniqueTileIds"):
      scene_data.uniqueTileIds = scene_json.uniqueTileIds
    else:
      scene_data.uniqueTileIds = {}
    scenes.append(scene_data)
  new_scene_list.emit(scenes)
