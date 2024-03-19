class_name DragonbiteTileSet
extends RefCounted

const tileClass = preload("res://Scripts/Data/Tile.gd")

var tiles:Array = []

func load_from_json(json:Array):
	for tileJson in json:
		var tile: Tile = tileClass.new()
		tile.create_tile_from_json(tileJson)
		tiles.append(tile)

func get_size() -> int:
	return tiles.size()
