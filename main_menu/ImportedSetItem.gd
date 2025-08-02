extends HBoxContainer

signal delete_pressed

func setText(text: String):
  $%Name.text = text

func forward_delete_pressed():
  delete_pressed.emit()