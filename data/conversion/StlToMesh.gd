class_name StlToMesh
extends RefCounted

#https://en.wikipedia.org/wiki/STL_(file_format)
class Triangle:
  var normal: Vector3
  var vertices: Array

var hash_input: PackedByteArray = PackedByteArray()
var mesh: ArrayMesh
var mesh_hash: String
var x_size: int
var y_size: int

func _init(source_path: String):
  mesh = stl_file_to_array_mesh(source_path)
  var hasher = HashingContext.new()
  hasher.start(HashingContext.HashType.HASH_SHA256)
  hasher.update(hash_input)
  mesh_hash = hasher.finish().hex_encode()

func stl_file_to_array_mesh(stl_file: String) -> ArrayMesh:
  var stl = FileAccess.open(stl_file, FileAccess.READ)

  var triangles = []
  if is_ascii(stl):
    return convert_ascii(stl)
  triangles = convert_binary(stl)
  triangles = position_mesh(triangles)
  hash_input.append(stl.get_length())
  stl.close()
  return save_mesh(triangles)

func is_ascii(file: FileAccess) -> bool:
  var current_pos = file.get_position()
  file.seek(0)
  # ASCII STL begins with "solid"
  var header = file.get_buffer(5)
  var result = header.get_string_from_ascii() == "solid"

  # Reset file position
  file.seek(current_pos)
  return result

func convert_binary(file: FileAccess) -> Array:
  #Skip header
  file.seek(80)

  #Read file
  var triangles = []
  var facet_count = file.get_32()
  for i in range(facet_count):
    var triangle = Triangle.new()
    var normal_x = file.get_float()
    var normal_y = file.get_float()
    var normal_z = file.get_float()
    triangle.normal = Vector3(normal_x, normal_y, normal_z)

    var vertices = []
    for j in range(3):
      var vertex_x = file.get_float()
      var vertex_y = file.get_float()
      var vertex_z = file.get_float()
      vertices.append(Vector3(vertex_x, vertex_y, vertex_z))
      append_vertex_to_hash_input(vertex_x)
      append_vertex_to_hash_input(vertex_y)
      append_vertex_to_hash_input(vertex_z)
    vertices.reverse()
    triangle.vertices = vertices
    triangles.append(triangle)

    # 2 unused bytes
    file.seek(file.get_position() + 2)
  return triangles

func append_vertex_to_hash_input(vertex: float):
  # Add vertex to hash input, truncating to thousandths place to avoid precision issues
  hash_input.append(int(vertex * 1000))

# Line up the mesh with the planning grid. For an odd length side, center the mesh
# for an even length side, offset the mesh by half a tile.
func position_mesh(triangles: Array) -> Array:
  #Center the mesh, calculate the bounding box
  var max_vertex: Vector3 = Vector3(-INF, -INF, -INF)
  var min_vertex: Vector3 = Vector3(INF, INF, INF)
  for triangle in triangles:
    for vertex in triangle.vertices:
      max_vertex = max_vector(max_vertex, vertex)
      min_vertex = min_vector(min_vertex, vertex)

  var center: Vector3 = (max_vertex + min_vertex) / 2
  x_size = get_tile_length(min_vertex.x, max_vertex.x)
  if x_size % 2 == 0:
    center.x -= 25
  y_size = get_tile_length(min_vertex.y, max_vertex.y)
  if y_size % 2 == 0:
    center.y += 25
  for triangle in triangles:
    for i in range(3):
      #Center the mesh, mesh is centered on x and z axis, and above Z axis
      #Rotation to make this be the right way up is in default tile
      triangle.vertices[i][0] -= center[0]
      triangle.vertices[i][1] -= center[1]
      triangle.vertices[i][2] -= min_vertex[2]
  return triangles

func save_mesh(triangles: Array) -> ArrayMesh:
  var surface_tool = SurfaceTool.new()
  surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
  for triangle in triangles:
    surface_tool.set_normal(triangle.normal)
    for vertex in triangle.vertices:
      surface_tool.add_vertex(vertex)
  return surface_tool.commit()

func max_vector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

func min_vector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

# Tiles are 50x50, return the tile length for a given min and max value, rounded to the nearest tile
func get_tile_length(min_val : float, max_val: float) -> int:
  var diff = max_val - min_val
  var tile_count = int(diff / 50)
  var leftover = diff - (tile_count * 50)
  if leftover >= 25:
    tile_count += 1
  return tile_count

# TODO Double check that this works
func convert_ascii(file: FileAccess) -> ArrayMesh:
  var surface_tool = SurfaceTool.new()
  surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
  # Skip header
  var line = file.get_line()
  var vertices = []
  while !file.eof_reached():
    line = file.get_line()
    match line.begins_with(line):
      "facet":
        var normal = line.split(" ").slice(2)
        surface_tool.set_normal(Vector3(
            normal[0].to_float(),
            normal[1].to_float(),
            normal[2].to_float()))
      "outer loop":
        vertices = []
      "vertex":
        var vertex = line.split(" ").slice(1)
        vertices.append(Vector3(
            vertex[0].to_float(),
            vertex[1].to_float(),
            vertex[2].to_float()))
      "endloop":
        vertices.reverse()
        for v in vertices:
          surface_tool.add_vertex(v)
      #Nothing to do on "endfacet" or "endsolid"
  return surface_tool.commit()
