extends Node3D

signal space_hover_enter(Node3D)
signal space_hover_exit(Node3D)
signal space_clicked(Node3D)

@onready var meshNode = $Area3D/MeshInstance3D

func update_context(context: PlanningContext.TileContext):
  meshNode.set_preview_context(context)

func set_tile(tile: PlanningContext.TileContext):
  meshNode.set_tile(tile)

func start_preview(tile: PlanningContext.TileContext):
  meshNode.start_preview(tile)

func end_preview():
  meshNode.exit_preview()

func _on_area_3d_input_event(_camera, event, _pos, _normal, _shape_idx):
  if not event is InputEventMouseButton:
    return
  event = event as InputEventMouseButton
  var buttonClicked = event.get_button_index()
  if not event.is_pressed() or buttonClicked != MOUSE_BUTTON_LEFT:
    return
  space_clicked.emit(self)

func _on_area_3d_mouse_entered():
  space_hover_enter.emit(self)


func _on_area_3d_mouse_exited():
  space_hover_exit.emit(self)
