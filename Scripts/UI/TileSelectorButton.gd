extends MarginContainer

var index = 0
signal tile_pressed(int)

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
  emit_signal("tile_pressed", index)
