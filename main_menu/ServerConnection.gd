class_name ServerConnection
extends Node

signal new_scene_list(scenes: Array)
signal scene_imported(sceneJson: Dictionary)

const SCENE_ADD_URL = "http://localhost:8080/scenes/add"
const SCENE_LIST_URL = "http://localhost:8080/scenes/list"
const SCENE_REQUEST_DATA_URL_TEMPLATE = "http://localhost:8080/scenes/%s"

func _ready() -> void:
  request_scene_list()

func request_scene_list() -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func (_result, _response_code, _headers, body: PackedByteArray) -> void:
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
      http_request.queue_free()
      new_scene_list.emit(scenes))
  http_request.request(SCENE_LIST_URL)

func request_scene_import(scene_id: String) -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func (_result, _response_code, _headers, body: PackedByteArray) -> void:
      var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
      http_request.queue_free()
      scene_imported.emit(json)
  )
  http_request.request(SCENE_REQUEST_DATA_URL_TEMPLATE % scene_id)

func upload_scene(scene: SceneData) -> void:
  var http_request := HTTPRequest.new()
  add_child(http_request)
  http_request.request_completed.connect(
    func (_result, response_code: int, _headers, _body) -> void:
      if response_code == 200:
        request_scene_list()
      else:
        print("Failed to upload scene.")
      http_request.queue_free()
  )
  var json_string = scene.to_server_json()
  var headers = ["Content-Type: application/json"]
  http_request.request(SCENE_ADD_URL, headers, HTTPClient.METHOD_PUT, json_string)
