extends MarginContainer

var index = 0
signal tile_pressed(int)

func set_image(imagePath:String):
	var image_texture = load(imagePath)
	$Button.icon = image_texture

func _on_button_pressed():
	emit_signal("tile_pressed", index)
