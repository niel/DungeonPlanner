extends MenuButton


signal new_scene()
signal save_scene()
signal save_scene_as()
signal load_scene(scene_name: String)
signal quit_scene()

const ID_NEW = 0
const ID_OPEN = 1
const ID_SAVE = 2
const ID_SAVE_AS = 3
const ID_QUIT = 4
const ID_SCENES_START = 100
const ID_SCENES_END = 199
const OPEN_SCENE_MENU_NAME = "OpenScene"

var open_menu: PopupMenu = PopupMenu.new()
var recent_scenes: Array = []

func _ready():
  var menu = get_popup()
  menu.add_item("New", ID_NEW)
  open_menu.id_pressed.connect(on_submenu_press.bind(OPEN_SCENE_MENU_NAME))
  menu.add_child(open_menu)
  menu.add_submenu_item("Open", open_menu.name, ID_OPEN)
  menu.add_item("Save", ID_SAVE)
  menu.id_pressed.connect(on_menu_button_id_pressed)
  menu.add_item("Save As", ID_SAVE_AS)
  menu.add_item("Quit", ID_QUIT)

func set_saves(save_names: Array):
  recent_scenes = save_names
  open_menu.clear()
  var idx = ID_SCENES_START
  for save_name in save_names:
    if idx > ID_SCENES_END:
      break
    open_menu.add_item(save_name, idx)
    idx += 1

func add_save(new_save: String):
  recent_scenes.append(new_save)
  var idx = ID_SCENES_START + recent_scenes.size() - 1
  if idx > ID_SCENES_END:
    print("Too many saves, not adding new save")
    return
  open_menu.add_item(new_save, idx)

func on_menu_button_id_pressed(id: int):
  match id:
    ID_NEW:
      new_scene.emit()
    ID_OPEN:
      # Handled by submenu
      pass
    ID_SAVE:
      save_scene.emit()
    ID_SAVE_AS:
      save_scene_as.emit()
    ID_QUIT:
      quit_scene.emit()


func on_submenu_press(id: int, menu_name: String):
  match menu_name:
    OPEN_SCENE_MENU_NAME:
      if id >= ID_SCENES_START and id <= ID_SCENES_END:
        load_scene.emit(recent_scenes[id - ID_SCENES_START])
