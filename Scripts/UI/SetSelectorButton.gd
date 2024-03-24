extends MarginContainer

var index = 0
signal set_button_pressed(int)

func set_text(newText: String):
  $Button.text = newText

func _on_button_pressed():
  set_button_pressed.emit(index)
