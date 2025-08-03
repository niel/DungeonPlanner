extends MeshInstance3D

const DEFAULT_MATERIAL = preload ("res://scene_builder/board/DefaultMaterial.tres")
const PREVIEW_MATERIAL = preload ("res://scene_builder/board/HoveredMaterial.tres")
const ERROR_MATERIAL = preload ("res://scene_builder/board/ErrorMaterial.tres")
const SPACE_MATERIAL = preload ("res://scene_builder/board/SpaceMaterial.tres")
const EMPTY_SPACE_MESH = preload ("res://scene_builder/board/SpaceMesh.tres")

# Defaults to empty
var selected_mesh: Mesh = EMPTY_SPACE_MESH
var tile_rotation = Vector3.ZERO
var is_space_mesh_set = false
var is_error = false

func exit_preview():
  mesh = selected_mesh
  set_rotation_degrees(tile_rotation)
  if get_active_material(0) == null:
    return
  if is_space_mesh_set:
    set_surface_override_material(0, DEFAULT_MATERIAL)
  else:
    set_surface_override_material(0, SPACE_MATERIAL)

func set_tile_context(context: PlanningContext.TileContext, new_is_error: bool = false):
  is_error = new_is_error
  visible = true
  var new_mesh: Mesh = context.mesh
  if new_mesh != null:
    mesh = new_mesh
    if get_active_material(0) != null:
      var new_material = PREVIEW_MATERIAL
      if is_error:
        new_material = ERROR_MATERIAL
      set_surface_override_material(0, new_material)
    set_rotation_degrees(context.rotation)

func set_tile(new_tile: PlanningContext.TileContext):
  visible = true
  if new_tile == null or get_active_material(0) == null:
    return
  set_surface_override_material(0, DEFAULT_MATERIAL)
  selected_mesh = new_tile.mesh
  mesh = selected_mesh
  tile_rotation = new_tile.rotation
  set_rotation_degrees(tile_rotation)
  is_space_mesh_set = true

func set_empty():
  visible = true
  set_surface_override_material(0, SPACE_MATERIAL)
  mesh = EMPTY_SPACE_MESH
  selected_mesh = EMPTY_SPACE_MESH
  tile_rotation = Vector3.ZERO
  set_rotation_degrees(Vector3.ZERO)
  is_space_mesh_set = false
