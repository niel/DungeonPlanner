extends Control

signal set_imported()

const IMPORT_STATUS_LABEL_TEMPLATE = "Importing %d tiles, currently %d/%d"

var file_loader = LoadSavedFiles.new()
var first_setup: bool = true
var import_tile_amount: int = 0
var imported_tiles_count: int = 0
var import_path: String = ""
var imported_set_name: String = ""
var import_thread = Thread.new()
var set_named: bool = false
var set_directory_selected: bool = false

@onready var action_buttons: HBoxContainer = $%ActionButtons
@onready var confirm_button: Button = $%Confirm
@onready var file_dialog: FileDialog = $%FileDialog
@onready var import_status_label: Label = $%ImportStatus
@onready var selected_dir_label: Label = $%SelectedDirLabel
@onready var set_name_input: LineEdit = $%NameInput

func initialize():
  visible = true
  if first_setup:
    file_loader.import_started.connect(setup_import_status_label)
    file_loader.tile_imported.connect(update_import_status_label)
    first_setup = false
  set_directory_selected = false
  imported_set_name = ""
  set_named = false
  import_path = ""
  selected_dir_label.text = "Not selected"
  set_name_input.text = imported_set_name
  action_buttons.visible = true
  import_status_label.visible = false
  update_confirm_button()

func _process(_delta: float) -> void:
  if import_thread.is_started() and not import_thread.is_alive():
    print("Import thread finished")
    import_thread.wait_to_finish()
    set_imported.emit()
    visible = false

func browse_pressed():
  file_dialog.popup_centered()

func on_import_directory_selected(path: String):
  if path == "":
    return
  selected_dir_label.text = path
  import_path = path
  set_directory_selected = true
  update_confirm_button()

func update_confirm_button():
  confirm_button.disabled = not (set_directory_selected and set_named)

func confirm_pressed():
  if import_path != "":
    action_buttons.visible = false
    import_thread.start(
        file_loader.import_tile_set_from_directory.bind(import_path, imported_set_name)
    )

func cancel_pressed():
  visible = false

func _on_set_name_text_changed(new_text: String) -> void:
  imported_set_name = new_text
  set_named = new_text != ""
  update_confirm_button()

func setup_import_status_label(total_tiles: int):
  import_tile_amount = total_tiles
  imported_tiles_count = 0
  import_status_label.text = IMPORT_STATUS_LABEL_TEMPLATE % [
      import_tile_amount,
      imported_tiles_count,
      import_tile_amount
  ]
  import_status_label.visible = true

func update_import_status_label():
  imported_tiles_count += 1
  import_status_label.text = IMPORT_STATUS_LABEL_TEMPLATE % [
      import_tile_amount,
      imported_tiles_count,
      import_tile_amount
  ]
