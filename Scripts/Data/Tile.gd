class_name Tile
extends RefCounted

var id = ""
var imagePath = ""
var meshPath = ""

func create_tile_from_json(json:Dictionary):
	id = json["id"]
	imagePath = json["imagePath"]
	meshPath = json["meshPath"]
