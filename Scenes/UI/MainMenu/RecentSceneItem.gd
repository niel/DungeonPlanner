extends HBoxContainer

signal delete_pressed
signal export_pressed
signal select_pressed

func setText(text: String):
  $%Name.text = text

func forward_delete_pressed():
  delete_pressed.emit()

func forward_export_pressed():
  export_pressed.emit()

func forward_select_pressed():
  select_pressed.emit()
