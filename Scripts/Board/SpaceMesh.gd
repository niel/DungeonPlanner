extends MeshInstance3D

var defaultMaterial = preload ("res://Materials/DefaultMaterial.tres")
var previewMaterial = preload ("res://Materials/HoveredMaterial.tres")
var errorMaterial = preload ("res://Materials/ErrorMaterial.tres")
var spaceMaterial = preload ("res://Materials/SpaceMaterial.tres")
var emptySpaceMesh = preload ("res://Meshes/SpaceMesh.tres")
var setMesh: Mesh = preload ("res://Meshes/SpaceMesh.tres")
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

func set_invisible(): 
  visible = false