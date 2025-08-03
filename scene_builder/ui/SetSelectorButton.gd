extends MarginContainer

signal set_button_pressed(int)

var index = 0

func update_state(set_vm: SetViewModel):
  if set_vm.hidden:
    $Button.visible = false
  else:
    $Button.visible = true
    index = set_vm.index
    $Button.disabled = false
    $Button.tooltip_text = set_vm.tile_set.name
    $Button.text = set_vm.tile_set.name

func _on_button_pressed():
  set_button_pressed.emit(index)
