extends MeshInstance3D

const defaultMaterial = preload ("res://scene_builder/board/DefaultMaterial.tres")
const previewMaterial = preload ("res://scene_builder/board/HoveredMaterial.tres")
const errorMaterial = preload ("res://scene_builder/board/ErrorMaterial.tres")
const spaceMaterial = preload ("res://scene_builder/board/SpaceMaterial.tres")
const emptySpaceMesh = preload ("res://scene_builder/board/SpaceMesh.tres")
# Defaults to empty
var setMesh: Mesh = emptySpaceMesh
var setRotation = Vector3.ZERO
var isSpaceMeshSet = false
var isError = false

func exit_preview():
  mesh = setMesh
  set_rotation_degrees(setRotation)
  if get_active_material(0) == null:
    return
  if isSpaceMeshSet:
    set_surface_override_material(0, defaultMaterial)
  else:
    set_surface_override_material(0, spaceMaterial)

func set_tile_context(context: PlanningContext.TileContext, newIsError: bool = false):
  isError = newIsError
  visible = true
  var selectedMesh: Mesh = context.mesh
  if selectedMesh != null:
    mesh = selectedMesh
    if get_active_material(0) != null:
      var newMaterial = previewMaterial
      if isError:
        newMaterial = errorMaterial
      set_surface_override_material(0, newMaterial)
    set_rotation_degrees(context.rotation)
  
func set_tile(newTile: PlanningContext.TileContext):
  visible = true
  if newTile == null or get_active_material(0) == null:
    return
  set_surface_override_material(0, defaultMaterial)
  setMesh = newTile.mesh
  mesh = setMesh
  setRotation = newTile.rotation
  set_rotation_degrees(setRotation)
  isSpaceMeshSet = true

func set_empty():
  visible = true
  set_surface_override_material(0, spaceMaterial)
  mesh = emptySpaceMesh
  setMesh = emptySpaceMesh
  setRotation = Vector3.ZERO
  set_rotation_degrees(Vector3.ZERO)
  isSpaceMeshSet = false
  
