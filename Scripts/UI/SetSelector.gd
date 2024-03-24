extends Control

class SetViewModel:
  var index: int
  var set: DragonbiteTileSet

signal set_selected(set: DragonbiteTileSet)

const setButtonScene = preload ("res://Scenes/UI/SetButton.tscn")
const setCount = 15

var selectableSets: Array = []
var setViewModels = []

@onready var setContainer = $SetSelector/Sets

func _ready():
  for i in range(setCount):
    var setVm = SetViewModel.new()
    setVm.index = i
    setVm.set = null
    setViewModels.append(setVm)
    
    var setButton = setButtonScene.instantiate()
    setButton.index = i
    setButton.set_button_pressed.connect(_on_button_pressed)
    setContainer.add_child(setButton)

func set_selectable_sets(sets: Array):
  selectableSets = sets
  update_view_models()

func update_view_models():
  for i in range(setCount):
    var setVm = setViewModels[i]
    setVm.index = i
    setVm.set = selectableSets[i % selectableSets.size()]
  update_buttons()

func update_buttons():
  for i in range(setCount):
    var currentVm = setViewModels[i]
    var setButton = setContainer.get_child(i)
    setButton.set_text(currentVm.set.name)

func _on_button_pressed(setIndex: int):
  set_selected.emit(setViewModels[setIndex].set)
