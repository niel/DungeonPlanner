class_name LoadSavedFiles
extends RefCounted

signal import_started(int)
signal tile_imported()

const TILE_PATH = "user://Meshes/"

func import_tile_set_from_directory(path: String, set_name: String):
  if SceneContext.get_set_names().has(set_name):
    print("Tile set with name ", set_name, " already exists")
    return
  var set_definition := {}
  var split_path = path.split("/")
  # Check path
  if split_path.size() == 0:
    print("Attempted to load tile set at empty path")
    return
  var set_definition_dir = DirAccess.open(path)
  if set_definition_dir == null:
    print("Failed to open ", DirAccess.get_open_error())
    return
  var new_set := DragonbiteTileSet.new()
  # Get name
  new_set.name = set_name
  set_definition["name"] = set_name
  # Get tiles and import stl files
  var tiles = []
  var stl_file_paths := set_definition_dir.get_files()
  call_deferred("emit_import_started", stl_file_paths.size())
  for file_name in stl_file_paths:
    if file_name.get_extension() != "stl":
      continue
    var new_tile = new_set.import_tile(path + "/" + file_name)
    var tile_definition = {}
    tile_definition[DragonbiteTileSet.KEY_TILE_NAME] = new_tile.name
    tile_definition[DragonbiteTileSet.KEY_TILE_ID] = new_tile.id
    var tile_res_path = TILE_PATH + set_name + "/" + new_tile.name + ".res"
    tile_definition[DragonbiteTileSet.KEY_TILE_RES_PATH] = tile_res_path
    tile_definition[DragonbiteTileSet.KEY_TILE_X_SIZE] = new_tile.x_size
    tile_definition[DragonbiteTileSet.KEY_TILE_Y_SIZE] = new_tile.y_size
    tiles.append(tile_definition)
    call_deferred("emit_tile_imported")
  set_definition["tiles"] = tiles
  # Save file
  var result = JSON.stringify(set_definition, "  ")
  var json_path = SceneContext.SET_DEFINITIONS_PATH + set_name + ".json"
  var set_definition_json = FileAccess.open(json_path, FileAccess.WRITE)
  set_definition_json.store_string(result)
  set_definition_json.close()
  SceneContext.tile_resources.add_set(new_set)

func emit_import_started(total_tiles: int):
  import_started.emit(total_tiles)

func emit_tile_imported():
  tile_imported.emit()
