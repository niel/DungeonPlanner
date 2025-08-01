extends MenuButton

const ID_NEW = 0
const ID_OPEN = 1
const ID_SAVE = 2
const ID_SAVE_AS = 3
const ID_QUIT = 4

signal new_scene()
signal save_scene()
signal save_scene_as()
signal load_scene(sceneName: String)
signal quit_scene()

const ID_SCENES_START = 100
const ID_SCENES_END = 199

var openMenu: PopupMenu = PopupMenu.new()
var recentScenes: Array = []

func _ready():
  var menu = get_popup()
  menu.add_item("New", ID_NEW)
  openMenu.id_pressed.connect(self.onSubmenuPress.bind("OpenScene"))
  menu.add_child(openMenu)
  menu.add_submenu_item("Open", openMenu.name, ID_OPEN)
  menu.add_item("Save", ID_SAVE)
  menu.id_pressed.connect(self._on_MenuButton_id_pressed)
  menu.add_item("Save As", ID_SAVE_AS)
  menu.add_item("Quit", ID_QUIT)

func set_saves(saveNames: Array):
  recentScenes = saveNames
  openMenu.clear()
  var idx = ID_SCENES_START
  for saveName in saveNames:
    if idx > ID_SCENES_END:
      break
    openMenu.add_item(saveName, idx)
    idx += 1

func add_save(newSave: String):
  recentScenes.append(newSave)
  var idx = ID_SCENES_START + recentScenes.size() - 1
  if idx > ID_SCENES_END:
    print("Too many saves, not adding new save")
    return
  openMenu.add_item(newSave, idx)

func _on_MenuButton_id_pressed(id: int):
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


func onSubmenuPress(id: int, menuName: String):
  match menuName:
    "OpenScene":
      if id >= ID_SCENES_START and id <= ID_SCENES_END:
        load_scene.emit(recentScenes[id - ID_SCENES_START])
