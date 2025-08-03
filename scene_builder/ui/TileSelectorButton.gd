extends MarginContainer

signal tile_pressed(int)

var index = 0

func update_state(tile_vm: TileViewModel):
  if tile_vm.hidden:
    $Button.visible = false
  else:
    $Button.visible = true
    index = tile_vm.index
    $Button.disabled = false
    $Button.tooltip_text = tile_vm.tile.name
    $Button.text = tile_vm.tile.name

func _on_button_pressed():
  tile_pressed.emit(index)
