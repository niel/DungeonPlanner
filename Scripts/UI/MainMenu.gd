extends PanelContainer

const planning_scene = preload("res://Scenes/PlannerScene.tscn")
const ui_recent_scene_item = preload("res://Scenes/UI/MainMenu/RecentSceneItem.tscn")

@onready var recentScenesContainer = $VBoxContainer/RecentScenes
var saveManager = SaveManager.new()

func _ready():
  saveManager = SaveManager.new()
  setup_recent_scenes()

func setup_recent_scenes():
  var recentScenes = saveManager.sceneNames
  for scene in recentScenes:
    var button = ui_recent_scene_item.instantiate()
    button.setText(scene)
    button.pressed.connect(load_recent_scene.bind(scene))
    recentScenesContainer.add_child(button)

func load_recent_scene(scene_name: String):
  print(scene_name)
  var sceneData = saveManager.load_scene_from_json(scene_name)
  var context = PlanningSceneContext.get_instance(self)
  context.currentScene = sceneData
  change_to_planning_scene()

func on_new_scene():
  change_to_planning_scene()

func change_to_planning_scene():
  var error = get_tree().change_scene_to_packed(planning_scene)
  if error != OK:
    print("Error loading planning scene: ", error)
