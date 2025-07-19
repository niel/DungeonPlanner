extends Control

signal import_directory_selected(path: String, name: String)

@onready var confirmButton: Button = $%Confirm
@onready var fileDialog: FileDialog = $%FileDialog
var firstSetup: bool = true
var importPath: String = ""
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

func browse_pressed():
  fileDialog.popup_centered()

func on_import_directory_selected(path: String):
  if path == "":
    return
  selectedDirLabel.text = path
  importPath = path
  setDirectorySelected = true
  update_confirm_button()

func confirm_pressed():
  if importPath != "":
    import_directory_selected.emit(importPath, setName)
    visible = false

func cancel_pressed():
  visible = false

func _on_set_name_text_changed(new_text:String) -> void:
  setName = new_text
  setNamed = new_text != ""
  update_confirm_button()

func update_confirm_button():
  confirmButton.disabled = not (setDirectorySelected and setNamed)
