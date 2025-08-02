extends MarginContainer

signal tile_pressed(int)

var index = 0

func update_state(tileVM: TileViewModel):
  if tileVM.hidden:
    $Button.visible = false
  else:
    $Button.visible = true
    index = tileVM.index
    $Button.disabled = false
    $Button.tooltip_text = tileVM.tile.name
    $Button.text = tileVM.tile.name

func _on_button_pressed():
  tile_pressed.emit(index)
