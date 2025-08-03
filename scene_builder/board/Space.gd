extends Node3D

signal space_hover_enter(Node3D)
signal space_hover_exit(Node3D)
signal space_clicked(Node3D, x, z)

var x = 0
var z = 0

@onready var mesh_node = $Area3D/MeshInstance3D

func update_context(context: PlanningContext.TileContext, is_error: bool):
  mesh_node.set_tile_context(context, is_error)

func set_tile(tile: PlanningContext.TileContext):
  mesh_node.set_tile(tile)

func start_preview(tile: PlanningContext.TileContext, is_error: bool):
  mesh_node.set_tile_context(tile, is_error)

func end_preview():
  mesh_node.exit_preview()

func _on_area_3d_input_event(_camera, event, _pos, _normal, _shape_idx):
  if not event is InputEventMouseButton:
    return
  event = event as InputEventMouseButton
  var button_clicked = event.get_button_index()
  if not event.is_pressed() or button_clicked != MOUSE_BUTTON_LEFT:
    return
  space_clicked.emit(self, x, z)

func _on_area_3d_mouse_entered():
  space_hover_enter.emit(self)

func _on_area_3d_mouse_exited():
  space_hover_exit.emit(self)

func set_empty():
  mesh_node.set_empty()
