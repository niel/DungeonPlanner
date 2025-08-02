extends MarginContainer

signal set_button_pressed(int)

var index = 0

func update_state(setVm: SetViewModel):
  if setVm.hidden:
    $Button.visible = false
  else:
    $Button.visible = true
    index = setVm.index
    $Button.disabled = false
    $Button.tooltip_text = setVm.tileSet.name
    $Button.text = setVm.tileSet.name

func _on_button_pressed():
  set_button_pressed.emit(index)
