extends MarginContainer

signal pressed

func setText(text: String):
  $Button.text = text

func forward_pressed():
  pressed.emit()
  