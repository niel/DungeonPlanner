class_name StlToMesh
extends RefCounted

#https://en.wikipedia.org/wiki/STL_(file_format)
class Triangle:
  var normal: Vector3
  var vertices: Array

var hash_input: PackedByteArray = PackedByteArray()
var mesh: ArrayMesh
var mesh_hash: String

func _init(sourcePath: String):
  mesh = stlFileToArrayMesh(sourcePath)
  var hasher = HashingContext.new()
  hasher.start(HashingContext.HashType.HASH_MD5)
  hasher.update(hash_input)
  mesh_hash = hasher.finish().hex_encode()

func stlFileToArrayMesh(stl_file: String) -> ArrayMesh:
  var stl = FileAccess.open(stl_file, FileAccess.READ)

  var triangles = []
  if isAscii(stl):
    return convertAscii(stl)
  else:
    triangles = convertBinary(stl)
  triangles = centerMesh(triangles)
  return saveMesh(triangles)

func isAscii(file: FileAccess) -> bool:
  var currentPos = file.get_position()
  file.seek(0)
  # ASCII STL begins with "solid"
  var header = file.get_buffer(5)
  var is_ascii = header.get_string_from_ascii() == "solid"
  
  # Reset file position
  file.seek(currentPos)
  return is_ascii

func convertBinary(file: FileAccess) -> Array:
  #Skip header
  file.seek(80)

  #Read file
  var triangles = []
  var facetCount = file.get_32()
  for i in range(facetCount):
    var triangle = Triangle.new()
    var normalX = file.get_float()
    var normalY = file.get_float()
    var normalZ = file.get_float()
    triangle.normal = Vector3(normalX, normalY, normalZ)

    var vertices = []
    for j in range(3):
      var vertexX = file.get_float()
      var vertexY = file.get_float()
      var vertexZ = file.get_float()
      vertices.append(Vector3(vertexX, vertexY, vertexZ))
      append_vertex_to_hash_input(vertexX)
      append_vertex_to_hash_input(vertexY)
      append_vertex_to_hash_input(vertexZ)
    vertices.reverse()
    triangle.vertices = vertices
    triangles.append(triangle)

    # 2 unused bytes
    file.seek(file.get_position() + 2)
  return triangles

func append_vertex_to_hash_input(vertex: float):
  # Add vertex to hash input, truncating to thousandths place to avoid precision issues
  hash_input.append(int(vertex * 1000))

func centerMesh(triangles: Array) -> Array:
  #Center the mesh, calculate the bounding box
  var maxVertex: Vector3 = Vector3(-INF, -INF, -INF)
  var minVertex: Vector3 = Vector3(INF, INF, INF)
  for triangle in triangles:
    for vertex in triangle.vertices:
      maxVertex = maxVector(maxVertex, vertex)
      minVertex = minVector(minVertex, vertex)

  var center: Vector3 = (maxVertex + minVertex) / 2
  for triangle in triangles:
    for i in range(3):
      #Center the mesh, mesh is centered on x and z axis, and above Z axis
      #Rotate to make this be the right way up is in default tile rotation 
      triangle.vertices[i][0] -= center[0]
      triangle.vertices[i][1] -= center[1]
      triangle.vertices[i][2] -= minVertex[2]

  maxVertex = Vector3(-INF, -INF, -INF)
  minVertex = Vector3(INF, INF, INF)
  for triangle in triangles:
    for vertex in triangle.vertices:
      maxVertex = maxVector(maxVertex, vertex)
      minVertex = minVector(minVertex, vertex)
  return triangles  
  
func saveMesh(triangles: Array) -> ArrayMesh:
  var surfaceTool = SurfaceTool.new()
  surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
  for triangle in triangles:
    surfaceTool.set_normal(triangle.normal)
    for vertex in triangle.vertices:
      surfaceTool.add_vertex(vertex)
  return surfaceTool.commit()

func maxVector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

func minVector(a: Vector3, b: Vector3) -> Vector3:
  return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

# TODO Double check that this works
func convertAscii(file: FileAccess) -> ArrayMesh:
  var surfaceTool = SurfaceTool.new()
  surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
  # Skip header
  var line = file.get_line()
  var vertices = []
  while !file.eof_reached():
    line = file.get_line()
    match line.begins_with(line):
      "facet":
        var normal = line.split(" ").slice(2)
        surfaceTool.set_normal(Vector3(normal[0].to_float(), normal[1].to_float(), normal[2].to_float()))
      "outer loop":
        vertices = []
      "vertex":
        var vertex = line.split(" ").slice(1)
        vertices.append(Vector3(vertex[0].to_float(), vertex[1].to_float(), vertex[2].to_float()))
      "endloop":
        vertices.reverse()
        for v in vertices:
          surfaceTool.add_vertex(v)
      #Nothing to do on "endfacet" or "endsolid"
  return surfaceTool.commit()
