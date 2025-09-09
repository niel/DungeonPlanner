class_name Scene
extends RefCounted

var author: String
var data: SceneData :
  set(value):
    data = value
    if data != null:
      set_unique_tile_ids()
var id: String
var scene_name: String
var unique_tile_ids: Dictionary = {}

func set_unique_tile_ids():
  unique_tile_ids.clear()
  for tile in data.tiles:
    if not unique_tile_ids.has(tile.id):
      unique_tile_ids.set(tile.id, 1)
