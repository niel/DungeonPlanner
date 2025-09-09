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
var uniqueTileIds: Dictionary = {}

func set_unique_tile_ids():
  uniqueTileIds.clear()
  for tile in data.tiles:
    if not uniqueTileIds.has(tile.id):
      uniqueTileIds.set(tile.id, 1)
