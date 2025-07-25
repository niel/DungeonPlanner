extends Control

signal set_imported()

const importStatusLabelTemplate = "Importing %d tiles, currently %d/%d"

@onready var actionButtons: HBoxContainer = $%ActionButtons
@onready var confirmButton: Button = $%Confirm
@onready var context := PlanningSceneContext.get_instance(self)
@onready var fileDialog: FileDialog = $%FileDialog
var firstSetup: bool = true
var importTileAmount: int = 0
var importedTilesCount: int = 0
var importPath: String = ""
@onready var importStatusLabel: Label = $%ImportStatus
var importThread = Thread.new()
@onready var selectedDirLabel: Label = $%SelectedDirLabel
var setName: String = ""
var setNamed: bool = false
@onready var setNameInput: LineEdit = $%NameInput
var setDirectorySelected: bool = false

func initialize():
  visible = true
  if firstSetup:
    firstSetup = false
  else:
    setDirectorySelected = false
    setName = ""
    setNamed = false
    importPath = ""
    selectedDirLabel.text = "Not selected"
    setNameInput.text = setName
    update_confirm_button()

func _process(_delta: float) -> void:
  if importThread.is_started() and not importThread.is_alive():
    print("Import thread finished")
    importThread.wait_to_finish()
    set_imported.emit()
    visible = false

func browse_pressed():
  fileDialog.popup_centered()

func on_import_directory_selected(path: String):
  if path == "":
    return
  selectedDirLabel.text = path
  importPath = path
  setDirectorySelected = true
  update_confirm_button()

func update_confirm_button():
  confirmButton.disabled = not (setDirectorySelected and setNamed)

func confirm_pressed():
  if importPath != "":
    context.import_started.connect(setup_import_status_label)
    context.tile_imported.connect(update_import_status_label)
    actionButtons.visible = false
    importThread.start(context.import_tile_set_from_directory.bind(importPath, setName))

func cancel_pressed():
  visible = false

func _on_set_name_text_changed(new_text:String) -> void:
  setName = new_text
  setNamed = new_text != ""
  update_confirm_button()

func setup_import_status_label(total_tiles: int):
  importTileAmount = total_tiles
  importedTilesCount = 0
  importStatusLabel.text = importStatusLabelTemplate % [importTileAmount, importedTilesCount, importTileAmount]
  importStatusLabel.visible = true

func update_import_status_label():
  importedTilesCount += 1
  importStatusLabel.text = importStatusLabelTemplate % [importTileAmount, importedTilesCount, importTileAmount]
